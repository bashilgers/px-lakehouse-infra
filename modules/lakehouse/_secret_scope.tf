# ===================================================================
# Secret Scope
# ===================================================================
# The key vault in Databricks, for the connections' and jobs' secrets.
# Creating a key vault-backed scope takes an Entra ID login that may change
# the key vault (Key Vault Contributor, Contributor or Owner): Databricks
# writes to it as the scope's creator. px-lakehouse-data's deploy service
# principle has no role on the key vault, so the scope is here. Every ACL is
# listed, the creator's included; workspace admins manage every scope anyway.

# Look up whoever applies this plan, the scope's creator. Read once the
# workspace exists.
data "databricks_current_user" "px_me" {
  provider   = databricks.workspace
  depends_on = [azurerm_databricks_workspace.px_databricks_workspace]
}

# Create key vault-backed secret scope
resource "databricks_secret_scope" "px_secret_scope" {
  provider = databricks.workspace
  name     = "${var.app_name}-keyvault"

  keyvault_metadata {
    resource_id = azurerm_key_vault.px_key_vault.id
    dns_name    = azurerm_key_vault.px_key_vault.vault_uri
  }

  # Databricks reads the secrets as the AzureDatabricks application
  depends_on = [azurerm_role_assignment.px_key_vault_databricks_secrets_user]
}

# The MANAGE that Databricks gives the scope's creator
resource "databricks_secret_acl" "px_secret_scope_creator" {
  provider   = databricks.workspace
  scope      = databricks_secret_scope.px_secret_scope.name
  principal  = data.databricks_current_user.px_me.user_name
  permission = "MANAGE"
}

# Let the run-as service principle and the other secret readers read the
# secrets. Nobody else gets an ACL: whoever can read the scope has the SQL
# service principle's secret, and whoever manages it can read it.
resource "databricks_secret_acl" "px_secret_scope_readers" {
  for_each   = toset(concat([data.databricks_service_principal.px_run_sp.application_id], var.secret_readers))
  provider   = databricks.workspace
  scope      = databricks_secret_scope.px_secret_scope.name
  principal  = each.key
  permission = "READ"

  # A principal gets an ACL only once it is in the workspace
  depends_on = [
    databricks_mws_permission_assignment.px_run_sp,
    databricks_mws_permission_assignment.px_persona,
  ]
}
