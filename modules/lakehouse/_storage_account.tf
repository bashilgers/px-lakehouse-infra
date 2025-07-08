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

# ===================================================================
# Create Storage Containers
# ===================================================================

# Add landing zone container
resource "azurerm_storage_container" "container_landing" {
  name                  = "landing"
  storage_account_id    = azurerm_storage_account.px_storage_account.id
  container_access_type = "private"
}

# Add bronze zone container
resource "azurerm_storage_container" "container_bronze" {
  name                  = "bronze"
  storage_account_id    = azurerm_storage_account.px_storage_account.id
  container_access_type = "private"
}

# Add silver zone container
resource "azurerm_storage_container" "container_silver" {
  name                  = "silver"
  storage_account_id    = azurerm_storage_account.px_storage_account.id
  container_access_type = "private"
}

# Add gold zone container
resource "azurerm_storage_container" "container_gold" {
  name                  = "gold"
  storage_account_id    = azurerm_storage_account.px_storage_account.id
  container_access_type = "private"
}
