# Register metastore for region in Unity Catalog 
resource "databricks_metastore" "uc_metastore" {
  provider      = databricks.account
  name          = "${var.app_name}-dbr-metastore"
  region        = azurerm_resource_group.uc_rg.location
  force_destroy = true
  storage_root  = format("abfss://%s@%s.dfs.core.windows.net/", azurerm_storage_container.uc_storage_account.name, azurerm_storage_account.uc_storage_account.name)
}

# Create connector for metastore to access data
resource "azurerm_databricks_access_connector" "uc_access_connector" {
  name                = "${var.app_name}-dbr-connector"
  resource_group_name = azurerm_resource_group.uc_rg.name
  location            = azurerm_resource_group.uc_rg.location
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
  depends_on = [ databricks_metastore.uc_metastore ]
}

# Provide access to the access connector that will be assumed by Unity Catalog to access data
resource "databricks_metastore_data_access" "uc_access_connector_data_access" {
  provider     = databricks.account
  metastore_id = databricks_metastore.uc_metastore.id
  name         = azurerm_databricks_access_connector.uc_access_connector.name
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.uc_access_connector.id
  }
  is_default    = true
  force_destroy = true
}