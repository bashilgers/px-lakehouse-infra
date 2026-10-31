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

# Create private endpoint rule from serverless compute to storage account (queue),
# which file events need to set up and read their queues
resource "databricks_mws_ncc_private_endpoint_rule" "px_ncc_storage_queue_private_endpoint_rule" {
  provider                       = databricks.account
  network_connectivity_config_id = databricks_mws_network_connectivity_config.px_ncc.network_connectivity_config_id
  resource_id                    = azurerm_storage_account.px_storage_account.id
  group_id                       = "queue"
}

# ===================================================================
# Unity Catalog Data Access
# ===================================================================
# The environment has its own access connector and storage credential, bound to
# its workspace, so its external locations (px-lakehouse-data) reach this
# storage account only. Access connectors are named dbr-<what they reach>-connector:
# dbr-adls-connector for this storage account, dbr-sqlsrv-connector for the sql
# server (_sql_database.tf). Their credentials take the same name.

# Create access connector for the environment's storage credential
resource "azurerm_databricks_access_connector" "px_dbr_adls_connector" {
  name                = "${var.app_name}-${var.env}-dbr-adls-connector"
  resource_group_name = azurerm_resource_group.px_rg.name
  location            = azurerm_resource_group.px_rg.location
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

# Let access connector read and write the data, for the external locations on this storage account
resource "azurerm_role_assignment" "px_dbr_adls_connector_storage_blob_data_contributor" {
  scope                = azurerm_storage_account.px_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.px_dbr_adls_connector.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

# Create storage credential on access connector, owned by the metastore admins
# since whoever owns it can reach all data the access connector can
resource "databricks_storage_credential" "px_dbr_adls_credential" {
  provider       = databricks.workspace
  name           = azurerm_databricks_access_connector.px_dbr_adls_connector.name
  owner          = var.metastore_admins_group_name
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  comment        = "Reads and writes ${azurerm_storage_account.px_storage_account.name}, for the external locations"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.px_dbr_adls_connector.id
  }

  # Made through the workspace, so only once it has the metastore, and deleted
  # before it loses it: a delete after that finds nothing and passes silently
  depends_on = [databricks_metastore_assignment.px_databricks_workspace_metastore]
}

# Bind storage credential to the environment's workspace only
resource "databricks_workspace_binding" "px_dbr_adls_credential" {
  provider       = databricks.workspace
  securable_type = "storage_credential"
  securable_name = databricks_storage_credential.px_dbr_adls_credential.name
  workspace_id   = azurerm_databricks_workspace.px_databricks_workspace.workspace_id
  binding_type   = "BINDING_TYPE_READ_WRITE"
}

# Let the environment's admin group, owner of its external locations (px-lakehouse-data),
# create external locations on the storage credential
resource "databricks_grant" "px_dbr_adls_credential_admins" {
  provider           = databricks.workspace
  storage_credential = databricks_storage_credential.px_dbr_adls_credential.id
  principal          = var.admins_group_name
  privileges         = ["CREATE_EXTERNAL_LOCATION"]
}

# ===================================================================
# Unity Catalog File Events
# ===================================================================
# File events on the external locations need the access connector to set up
# storage queues and event grid subscriptions for this storage account.

# Let access connector configure the storage account's event setup
resource "azurerm_role_assignment" "px_dbr_adls_connector_storage_account_contributor" {
  scope                = azurerm_storage_account.px_storage_account.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_databricks_access_connector.px_dbr_adls_connector.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

# Let access connector read and write the storage queues
resource "azurerm_role_assignment" "px_dbr_adls_connector_storage_queue_data_contributor" {
  scope                = azurerm_storage_account.px_storage_account.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_databricks_access_connector.px_dbr_adls_connector.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

# Let access connector create event grid subscriptions in the resource group
resource "azurerm_role_assignment" "px_dbr_adls_connector_eventgrid_subscription_contributor" {
  scope                = azurerm_resource_group.px_rg.id
  role_definition_name = "EventGrid EventSubscription Contributor"
  principal_id         = azurerm_databricks_access_connector.px_dbr_adls_connector.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
