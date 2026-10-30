# ===================================================================
# Central KeyVault for Environment
# ===================================================================
# Access to the secrets goes through Azure RBAC, not access policies: with
# access policies, whoever may change the key vault can give themselves its
# secrets. Granting a role takes Owner or User Access Administrator.

# Create basic keyvault resource, with azure rbac for its data
resource "azurerm_key_vault" "px_key_vault" {
  name                        = "${var.app_name}-${var.env}-kv"
  resource_group_name         = azurerm_resource_group.px_rg.name
  location                    = azurerm_resource_group.px_rg.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  rbac_authorization_enabled  = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  tags                        = var.tags
}

# Look up key vault managers group in entra id (user_management)
data "azuread_group" "px_keyvault_managers" {
  display_name     = "${var.app_name}-${var.env}-keyvault-managers"
  security_enabled = true
}

# Let the key vault managers manage secrets
resource "azurerm_role_assignment" "px_key_vault_managers_secrets_officer" {
  scope                = azurerm_key_vault.px_key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azuread_group.px_keyvault_managers.object_id
  principal_type       = "Group"
}

# Let the key vault managers find the key vault in the azure portal
resource "azurerm_role_assignment" "px_key_vault_managers_reader" {
  scope                = azurerm_key_vault.px_key_vault.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.px_keyvault_managers.object_id
  principal_type       = "Group"
}

# Let databricks read secrets through key vault-backed secret scopes
resource "azurerm_role_assignment" "px_key_vault_databricks_secrets_user" {
  scope                = azurerm_key_vault.px_key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.azure_databricks_object_id
  principal_type       = "ServicePrincipal"
}

# Create private endpoint rule from serverless compute to keyvault
resource "databricks_mws_ncc_private_endpoint_rule" "px_ncc_key_vault_private_endpoint_rule" {
  provider                       = databricks.account
  network_connectivity_config_id = databricks_mws_network_connectivity_config.px_ncc.network_connectivity_config_id
  resource_id                    = azurerm_key_vault.px_key_vault.id
  group_id                       = "vault"
}
