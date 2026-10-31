# ===================================================================
# Persona Groups in Entra ID (per environment)
# ===================================================================
# The people who use an environment's data get access through these groups,
# never one by one: engineers build and run the pipelines, readers query the
# gold layer, support watches the loads. Their grants are in px-lakehouse-data.
# Membership is managed in Entra ID, not here, and Databricks takes it from
# there through automatic identity management. Each environment's lakehouse
# plan resolves its groups into the Databricks account and assigns them to its
# workspace. An environment has only the personas it lists: prod has no
# engineers.

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

  # Membership is managed in Entra ID, not in this code
  lifecycle {
    ignore_changes = [members]
  }
}
