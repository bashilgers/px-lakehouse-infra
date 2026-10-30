# ===================================================================
# Persona Groups in Entra ID (per environment)
# ===================================================================
# The people who use an environment's data get access through these groups,
# never one by one: engineers build and run the pipelines, readers query the
# gold layer, support watches the loads. Their grants are in px-lakehouse-data.
# Membership is managed in Entra ID, not here, and Databricks takes it from
# there through automatic identity management. A new group is resolved into
# the Databricks account once (databricks account iam-v2 resolve-group
# <object id>) before it can be assigned or granted: for a new environment or
# persona, apply the groups first
# (-target=module.user_management.azuread_group.px_persona), resolve them, then
# apply the rest.

locals {
  personas = {
    engineers = "Data engineers of %s: read all its data; in dev also create their own schemas"
    readers   = "Readers of %s: query its gold layer"
    support   = "Support of %s: watch its loads through the run logs, landing files and bronze"
  }

  # One entry per environment and persona
  env_personas = {
    for pair in setproduct(keys(var.environments), keys(local.personas)) :
    "${pair[0]}/${pair[1]}" => { env = pair[0], persona = pair[1] }
  }
}

# Create security group in entra id per environment and persona
resource "azuread_group" "px_persona" {
  for_each                = local.env_personas
  display_name            = "${var.app_name}-${each.value.env}-${each.value.persona}"
  description             = format(local.personas[each.value.persona], "${var.app_name}-${each.value.env}")
  security_enabled        = true
  prevent_duplicate_names = true
  owners                  = var.group_owner_object_ids

  # Membership is managed in Entra ID, not in this code
  lifecycle {
    ignore_changes = [members]
  }
}

# Look up persona group in databricks account, once resolved from entra id
data "databricks_group" "px_persona" {
  for_each     = local.env_personas
  provider     = databricks.account
  display_name = azuread_group.px_persona[each.key].display_name
}

# Give persona group access to its environment's workspace. The workspace's
# users group has no entitlements, so each group gets its own (lakehouse).
resource "databricks_mws_permission_assignment" "px_persona" {
  for_each     = { for key, env_persona in local.env_personas : key => env_persona if contains(keys(local.workspace_environments), env_persona.env) }
  provider     = databricks.account
  workspace_id = var.environments[each.value.env].workspace_id
  principal_id = data.databricks_group.px_persona[each.key].id
  permissions  = ["USER"]
}
