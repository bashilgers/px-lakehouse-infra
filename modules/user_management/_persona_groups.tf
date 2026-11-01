# ===================================================================
# Persona Groups in Entra ID (per environment)
# ===================================================================
# The people who use an environment's data get access through these groups,
# never one by one: engineers build and run the pipelines, readers query the
# gold layer, support watches the loads. Their grants are in px-lakehouse-data.
# Membership is managed in Entra ID, not here, and Databricks takes it from
# there through automatic identity management. The group's copy in the
# Databricks account is made here too, linked to the Entra group by its object
# ID, as automatic identity management would make it: a destroy then deletes
# it, which a group resolved on first use outlives. Each environment's
# lakehouse plan assigns its groups to its workspace. An environment has only
# the personas it lists: prod has no engineers.

locals {
  personas = {
    engineers = "Data engineers of %s: read all its data; in dev also create their own schemas"
    readers   = "Readers of %s: query its gold layer"
    support   = "Support of %s: watch its loads through the run logs, landing files and bronze"
  }

  # One entry per environment and each of its personas
  env_personas = merge([
    for env, environment in var.environments : {
      for persona in environment.personas : "${env}/${persona}" => { env = env, persona = persona }
    }
  ]...)
}

# Create security group in entra id per environment and persona
resource "azuread_group" "px_persona" {
  for_each                = local.env_personas
  display_name            = "${var.app_name}-${each.value.env}-${each.value.persona}"
  description             = format(local.personas[each.value.persona], "${var.app_name}-${each.value.env}")
  security_enabled        = true
  prevent_duplicate_names = true
  owners                  = var.group_owner_object_ids
  members                 = var.group_member_object_ids

  # Membership is managed in Entra ID, not in this code: the members above are
  # only the first ones
  lifecycle {
    ignore_changes = [members]
  }
}

# Create the persona group in the databricks account, linked to its entra group
resource "databricks_account_iam_group_v2" "px_persona" {
  for_each    = local.env_personas
  provider    = databricks.account
  group_name  = azuread_group.px_persona[each.key].display_name
  external_id = azuread_group.px_persona[each.key].object_id
}
