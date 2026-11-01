# ===================================================================
# Workspace Access
# ===================================================================
# Who can use the workspace, and with which entitlements. The identities come
# from user_management; this plan looks them up in the Databricks account and
# assigns them to the workspace it creates, so neither plan waits for the
# other. The workspace's users group has no entitlements, so being assigned
# alone gives no access: the persona groups and the deploy service principal
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
# service principal (user_management)
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

# Manage the resolved group, so a destroy deletes it: nothing else would when
# its entra group goes, and the next build's group of the same name would
# clash with it. Automatic identity management refuses to create one through
# this resource, so the plan imports the resolved one (its import block is in
# plans/<env>/main.tf, as import blocks live in the root module).
resource "databricks_group" "px_persona" {
  for_each     = local.persona_entitlements
  provider     = databricks.account
  display_name = data.azuread_group.px_persona[each.key].display_name
  external_id  = data.azuread_group.px_persona[each.key].object_id
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

# Give the deploy and run-as service principals access to the workspace
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
  principal_id = databricks_group.px_persona[each.key].id
  permissions  = ["USER"]
}

# Give persona group its entitlements in the workspace: engineers and support
# the workspace and Databricks SQL, readers Databricks SQL only. Support needs
# the workspace to follow job runs.
resource "databricks_entitlements" "px_persona" {
  for_each              = local.persona_entitlements
  provider              = databricks.workspace
  group_id              = databricks_group.px_persona[each.key].id
  workspace_access      = each.value.workspace_access
  databricks_sql_access = each.value.databricks_sql_access

  depends_on = [databricks_mws_permission_assignment.px_persona]
}

# Give the deploy service principal both entitlements. It applies
# px-lakehouse-data's Terraform through the workspace's APIs, which refuse a
# caller without the workspace or Databricks SQL entitlement.
resource "databricks_entitlements" "px_deploy_sp" {
  provider              = databricks.workspace
  service_principal_id  = data.databricks_service_principal.px_deploy_sp.id
  workspace_access      = true
  databricks_sql_access = true

  depends_on = [databricks_mws_permission_assignment.px_deploy_sp]
}

# Look up the deploy service principal in entra id (user_management)
data "azuread_service_principal" "px_deploy_sp" {
  display_name = "${var.app_name}-${var.env}-deploy-sp"
}

# Let the deploy service principal read the workspace resource: px-lakehouse-data
# names its workspace by Azure resource ID, which stays the same through a
# rebuild, and the Databricks provider reads the workspace URL from it. Reader
# gives no rights in the workspace itself.
resource "azurerm_role_assignment" "px_deploy_sp_workspace_reader" {
  scope                = azurerm_databricks_workspace.px_databricks_workspace.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_service_principal.px_deploy_sp.object_id
  principal_type       = "ServicePrincipal"
}
