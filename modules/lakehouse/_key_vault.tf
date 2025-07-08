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
