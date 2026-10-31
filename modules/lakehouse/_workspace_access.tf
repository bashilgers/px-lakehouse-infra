# ===================================================================
# Workspace Access
# ===================================================================
# Who can use the workspace, and with which entitlements. The identities come
# from user_management; this plan looks them up in the Databricks account and
# assigns them to the workspace it creates, so neither plan waits for the
# other. The workspace's users group has no entitlements, so being assigned
# alone gives no access: the persona groups and the deploy service principle
# get their own. Workspace and account report the same principal IDs (identity
# federation), so the entitlements use the account's.

locals {
  # Only the environment's own personas (var.personas)
  persona_entitlements = {
    for persona, entitlements in {
      engineers = { workspace_access = true, databricks_sql_access = true }
      readers   = { workspace_access = false, databricks_sql_access = true }
      support   = { workspace_access = true, databricks_sql_access = true }
    } : persona => entitlements if contains(var.personas, persona)
  }
}

# Look up the environment's admin group, the metastore admins and the run-as
# service principle (user_management)
data "databricks_group" "px_env_admins" {
  provider     = databricks.account
  display_name = var.admins_group_name
}

data "databricks_group" "px_metastore_admins" {
  provider     = databricks.account
  display_name = var.metastore_admins_group_name
}

data "databricks_service_principal" "px_run_sp" {
  provider     = databricks.account
  display_name = "${var.app_name}-${var.env}-run-sp"
}

# Look up persona group in entra id (user_management), and resolve it into the
# Databricks account: reading the external group provisions it there the first
# time, as automatic identity management doesn't until a group is used
data "azuread_group" "px_persona" {
  for_each         = local.persona_entitlements
  display_name     = "${var.app_name}-${var.env}-${each.key}"
  security_enabled = true
}

data "databricks_account_iam_external_group_v2" "px_persona" {
  for_each = local.persona_entitlements
  provider = databricks.account
  name     = "accounts/${var.databricks_account_id}/external-groups/${data.azuread_group.px_persona[each.key].object_id}"
}

# Give the environment's admin group access to its own workspace only
resource "databricks_mws_permission_assignment" "px_env_admins" {
  provider     = databricks.account
  workspace_id = azurerm_databricks_workspace.px_databricks_workspace.workspace_id
  principal_id = data.databricks_group.px_env_admins.id
  permissions  = ["USER"]
}

# Give the metastore admins access to the workspace, for their MANAGE on the
# secret scope. Its members, the admin users, are workspace admins already.
resource "databricks_mws_permission_assignment" "px_metastore_admins" {
  provider     = databricks.account
  workspace_id = azurerm_databricks_workspace.px_databricks_workspace.workspace_id
  principal_id = data.databricks_group.px_metastore_admins.id
  permissions  = ["USER"]
}

# Give the deploy and run-as service principles access to the workspace
resource "databricks_mws_permission_assignment" "px_deploy_sp" {
  provider     = databricks.account
  workspace_id = azurerm_databricks_workspace.px_databricks_workspace.workspace_id
  principal_id = data.databricks_service_principal.px_deploy_sp.id
  permissions  = ["USER"]
}

resource "databricks_mws_permission_assignment" "px_run_sp" {
  provider     = databricks.account
  workspace_id = azurerm_databricks_workspace.px_databricks_workspace.workspace_id
  principal_id = data.databricks_service_principal.px_run_sp.id
  permissions  = ["USER"]
}

# Give persona group access to the workspace
resource "databricks_mws_permission_assignment" "px_persona" {
  for_each     = local.persona_entitlements
  provider     = databricks.account
  workspace_id = azurerm_databricks_workspace.px_databricks_workspace.workspace_id
  principal_id = data.databricks_account_iam_external_group_v2.px_persona[each.key].internal_id
  permissions  = ["USER"]
}

# Give persona group its entitlements in the workspace: engineers and support
# the workspace and Databricks SQL, readers Databricks SQL only. Support needs
# the workspace to follow job runs.
resource "databricks_entitlements" "px_persona" {
  for_each              = local.persona_entitlements
  provider              = databricks.workspace
  group_id              = data.databricks_account_iam_external_group_v2.px_persona[each.key].internal_id
  workspace_access      = each.value.workspace_access
  databricks_sql_access = each.value.databricks_sql_access

  depends_on = [databricks_mws_permission_assignment.px_persona]
}

# Give the deploy service principle both entitlements. It applies
# px-lakehouse-data's Terraform through the workspace's APIs, which refuse a
# caller without the workspace or Databricks SQL entitlement.
resource "databricks_entitlements" "px_deploy_sp" {
  provider              = databricks.workspace
  service_principal_id  = data.databricks_service_principal.px_deploy_sp.id
  workspace_access      = true
  databricks_sql_access = true

  depends_on = [databricks_mws_permission_assignment.px_deploy_sp]
}
