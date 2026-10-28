# ===================================================================
# Central KeyVault for Environment
# ===================================================================

# Create basic keyvault resource
resource "azurerm_key_vault" "px_key_vault" {
  name                        = "${var.app_name}-${var.env}-kv"
  resource_group_name         = azurerm_resource_group.px_rg.name
  location                    = azurerm_resource_group.px_rg.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  tags                        = var.tags
}

# Let the key vault admin manage secrets
resource "azurerm_key_vault_access_policy" "px_key_vault_admin" {
  key_vault_id       = azurerm_key_vault.px_key_vault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = var.key_vault_admin_object_id
  secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
}

# Let databricks read secrets through key vault-backed secret scopes
resource "azurerm_key_vault_access_policy" "px_key_vault_databricks" {
  key_vault_id       = azurerm_key_vault.px_key_vault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = var.azure_databricks_object_id
  secret_permissions = ["Get", "List"]
}

# Create private endpoint rule from serverless compute to keyvault
resource "databricks_mws_ncc_private_endpoint_rule" "px_ncc_key_vault_private_endpoint_rule" {
  provider                       = databricks.account
  network_connectivity_config_id = databricks_mws_network_connectivity_config.px_ncc.network_connectivity_config_id
  resource_id                    = azurerm_key_vault.px_key_vault.id
  group_id                       = "vault"
}
