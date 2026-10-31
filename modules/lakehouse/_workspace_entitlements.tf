# ===================================================================
# Persona Group Entitlements
# ===================================================================
# The workspace's users group has no entitlements, so being assigned to the
# workspace alone gives no access. The environment's persona groups
# (user_management, assigned there) get their own: engineers and support the
# workspace and Databricks SQL, readers Databricks SQL only. Support needs the
# workspace to follow job runs.

locals {
  persona_entitlements = {
    engineers = { workspace_access = true, databricks_sql_access = true }
    readers   = { workspace_access = false, databricks_sql_access = true }
    support   = { workspace_access = true, databricks_sql_access = true }
  }
}

# Look up persona group in the workspace, where user_management assigned it.
# For a new environment that means: apply its workspace and metastore
# assignment first (-target), then user_management with the workspace's ID,
# then the rest of this plan.
data "databricks_group" "px_persona" {
  for_each     = local.persona_entitlements
  provider     = databricks.workspace
  display_name = "${var.app_name}-${var.env}-${each.key}"
}

# Give persona group its entitlements in the workspace
resource "databricks_entitlements" "px_persona" {
  for_each              = local.persona_entitlements
  provider              = databricks.workspace
  group_id              = data.databricks_group.px_persona[each.key].id
  workspace_access      = each.value.workspace_access
  databricks_sql_access = each.value.databricks_sql_access
}

# ===================================================================
# Deploy Service Principle Entitlements
# ===================================================================
# The environment's deploy service principle (user_management) applies
# px-lakehouse-data's Terraform through the workspace's APIs, which refuse a
# caller without the workspace or Databricks SQL entitlement. It gets both, as
# dev's had by hand before this.

# Look up deploy service principle in the workspace, where user_management assigned it
data "databricks_service_principal" "px_deploy_sp_workspace" {
  provider       = databricks.workspace
  application_id = data.databricks_service_principal.px_deploy_sp.application_id
}

# Give deploy service principle its entitlements in the workspace
resource "databricks_entitlements" "px_deploy_sp" {
  provider              = databricks.workspace
  service_principal_id  = data.databricks_service_principal.px_deploy_sp_workspace.id
  workspace_access      = true
  databricks_sql_access = true
}
