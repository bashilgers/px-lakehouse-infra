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

# ===================================================================
# Serverless Access to Storage Account
# ===================================================================

# Create private endpoint rule from serverless compute to storage account (dfs)
resource "databricks_mws_ncc_private_endpoint_rule" "px_ncc_storage_dfs_private_endpoint_rule" {
  provider                       = databricks.account
  network_connectivity_config_id = databricks_mws_network_connectivity_config.px_ncc.network_connectivity_config_id
  resource_id                    = azurerm_storage_account.px_storage_account.id
  group_id                       = "dfs"
}

# Create private endpoint rule from serverless compute to storage account (blob)
resource "databricks_mws_ncc_private_endpoint_rule" "px_ncc_storage_blob_private_endpoint_rule" {
  provider                       = databricks.account
  network_connectivity_config_id = databricks_mws_network_connectivity_config.px_ncc.network_connectivity_config_id
  resource_id                    = azurerm_storage_account.px_storage_account.id
  group_id                       = "blob"
}
