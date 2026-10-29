# ===================================================================
# Run-as Service Principles for Databricks Jobs (one per environment)
# ===================================================================
# The environment's jobs and pipelines run as this one; nothing logs in as it.
# It has no secret, no federated credential and no Azure roles: Databricks runs
# jobs as it without any. Its data access is granted in px-lakehouse-data.
# Replaces px-lakehouse-sp (_service_principles.tf).

# Create app in app registry per environment
resource "azuread_application_registration" "px_run_sp" {
  for_each     = var.environments
  display_name = "${var.app_name}-${each.key}-run-sp"
  description  = "Run-as identity of the ${each.key} Databricks jobs and pipelines"
}

# Grab client_id of app and create service principle per environment
resource "azuread_service_principal" "px_run_sp" {
  for_each  = var.environments
  client_id = azuread_application_registration.px_run_sp[each.key].client_id
}

# Register run-as service principle in databricks account
resource "databricks_service_principal" "px_run_sp" {
  for_each       = var.environments
  provider       = databricks.account
  application_id = azuread_application_registration.px_run_sp[each.key].client_id
  display_name   = "${var.app_name}-${each.key}-run-sp"
}

# Give run-as service principle access to its environment's workspace
resource "databricks_mws_permission_assignment" "px_run_sp" {
  for_each     = var.environments
  provider     = databricks.account
  workspace_id = each.value.workspace_id
  principal_id = databricks_service_principal.px_run_sp[each.key].id
  permissions  = ["USER"]
}

# Let the environment's deploy service principle deploy jobs that run as it
# (Service Principal User), and the admin users manage it. Authoritative: these
# are all its roles, the creator's default manager role included.
resource "databricks_access_control_rule_set" "px_run_sp" {
  for_each = var.environments
  provider = databricks.account
  name     = "accounts/${var.databricks_account_id}/servicePrincipals/${databricks_service_principal.px_run_sp[each.key].application_id}/ruleSets/default"

  grant_rules {
    principals = [databricks_service_principal.px_deploy_sp[each.key].acl_principal_id]
    role       = "roles/servicePrincipal.user"
  }

  grant_rules {
    principals = [for user in var.admin_user_names : data.databricks_user.px_admins[user].acl_principal_id]
    role       = "roles/servicePrincipal.manager"
  }
}
