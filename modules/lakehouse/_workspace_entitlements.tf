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

# Look up persona group in the workspace, where user_management assigned it
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
