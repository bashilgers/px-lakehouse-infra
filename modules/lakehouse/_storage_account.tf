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

# Add catalog container, the managed storage of the environment's catalog (px-lakehouse-data)
resource "azurerm_storage_container" "container_catalog" {
  name                  = "catalog"
  storage_account_id    = azurerm_storage_account.px_storage_account.id
  container_access_type = "private"

  # Holds every managed table of the environment
  lifecycle {
    prevent_destroy = true
  }
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

# ===================================================================
# Unity Catalog Data Access
# ===================================================================

# Let access connector read and write the data, for the external locations on this storage account
resource "azurerm_role_assignment" "px_access_connector_storage_blob_data_contributor" {
  scope                = azurerm_storage_account.px_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.access_connector_principal_id
  principal_type       = "ServicePrincipal"
}

# ===================================================================
# Unity Catalog File Events
# ===================================================================
# File events on the external locations need the access connector to set up
# storage queues and event grid subscriptions for this storage account.

# Let access connector configure the storage account's event setup
resource "azurerm_role_assignment" "px_access_connector_storage_account_contributor" {
  scope                = azurerm_storage_account.px_storage_account.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = var.access_connector_principal_id
  principal_type       = "ServicePrincipal"
}

# Let access connector read and write the storage queues
resource "azurerm_role_assignment" "px_access_connector_storage_queue_data_contributor" {
  scope                = azurerm_storage_account.px_storage_account.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = var.access_connector_principal_id
  principal_type       = "ServicePrincipal"
}

# Let access connector create event grid subscriptions in the resource group
resource "azurerm_role_assignment" "px_access_connector_eventgrid_subscription_contributor" {
  scope                = azurerm_resource_group.px_rg.id
  role_definition_name = "EventGrid EventSubscription Contributor"
  principal_id         = var.access_connector_principal_id
  principal_type       = "ServicePrincipal"
}
