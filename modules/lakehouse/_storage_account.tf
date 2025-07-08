# ===================================================================
# Storage Account as OneLake for Environment
# ===================================================================

# Create basic azure data lake storage account
resource "azurerm_storage_account" "px_storage_account" {
  name                     = replace("${var.app_name}-${var.env}-sa-02", "-", "")
  location                 = azurerm_resource_group.px_rg.location
  resource_group_name      = azurerm_resource_group.px_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  tags                     = var.tags
}

# TODO containers
