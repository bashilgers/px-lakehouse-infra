# ===================================================================
# Run-as Service Principals for Databricks Jobs (one per environment)
# ===================================================================
# The environment's jobs and pipelines run as this one; nothing logs in as it.
# It has no secret, no federated credential and no Azure roles: Databricks runs
# jobs as it without any. Its data access is granted in px-lakehouse-data.
# Replaces px-lakehouse-sp (_service_principals.tf).

# Create app in app registry per environment
resource "azuread_application_registration" "px_run_sp" {
  for_each     = var.environments
  display_name = "${var.app_name}-${each.key}-run-sp"
  description  = "Run-as identity of the ${each.key} Databricks jobs and pipelines"
}

# Grab client_id of app and create service principal per environment
resource "azuread_service_principal" "px_run_sp" {
  for_each  = var.environments
  client_id = azuread_application_registration.px_run_sp[each.key].client_id
}

# Register run-as service principal in databricks account
resource "databricks_service_principal" "px_run_sp" {
  for_each       = var.environments
  provider       = databricks.account
  application_id = azuread_application_registration.px_run_sp[each.key].client_id
  display_name   = "${var.app_name}-${each.key}-run-sp"

  # Delete it on destroy; on account level the provider only deactivates it
  # by default, and a rebuild then finds two by this name
  disable_as_user_deletion = false
}

# Let the environment's deploy service principal deploy jobs that run as it
# (Service Principal User), and the metastore admins, the admin users' group,
# manage it. Authoritative: these are all its roles, so the manager role
# Databricks gives its creator is taken away.
resource "databricks_access_control_rule_set" "px_run_sp" {
  for_each = var.environments
  provider = databricks.account
  name     = "accounts/${var.databricks_account_id}/servicePrincipals/${databricks_service_principal.px_run_sp[each.key].application_id}/ruleSets/default"

  grant_rules {
    principals = [databricks_service_principal.px_deploy_sp[each.key].acl_principal_id]
    role       = "roles/servicePrincipal.user"
  }

  grant_rules {
    principals = [databricks_group.px_metastore_admins.acl_principal_id]
    role       = "roles/servicePrincipal.manager"
  }
}
