# ===================================================================
# Persona Groups in Entra ID (per environment)
# ===================================================================
# The people who use an environment's data get access through these groups,
# never one by one: engineers build and run the pipelines, readers query the
# gold layer. Their grants are in px-lakehouse-data. Membership is managed in
# Entra ID, not here, and Databricks takes it from there through automatic
# identity management; resolve a new group into the Databricks account once
# (databricks account iam-v2 resolve-group <object id>) before granting it.

locals {
  personas = {
    engineers = "Data engineers of %s: read all its data; in dev also create their own schemas"
    readers   = "Readers of %s: query its gold layer"
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
