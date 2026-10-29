# Register metastore for region in Unity Catalog 
resource "databricks_metastore" "uc_metastore" {
  provider     = databricks.account
  name         = "${var.app_name}-dbr-metastore"
  region       = azurerm_resource_group.uc_rg.location
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/", azurerm_storage_container.uc_storage_account.name, azurerm_storage_account.uc_storage_account.name)
  # Owned by a humans-only group, whose members are the metastore admins
  owner = var.metastore_admins_group_name

  lifecycle {
    # Set outside this resource: the root credential is the access connector
    # below, and the token lifetime is left at the account's default
    ignore_changes = [storage_root_credential_name, delta_sharing_recipient_token_lifetime_in_seconds]
  }
}

# Create connector for metastore to access data
resource "azurerm_databricks_access_connector" "uc_access_connector" {
  name                = "${var.app_name}-dbr-connector"
  resource_group_name = azurerm_resource_group.uc_rg.name
  location            = azurerm_resource_group.uc_rg.location
  identity {
    type = "SystemAssigned"
  }
  tags       = var.tags
  depends_on = [databricks_metastore.uc_metastore]
}

# Provide access to the access connector that will be assumed by Unity Catalog to access data
resource "databricks_storage_credential" "uc_storage_credential" {
  provider = databricks.workspace
  name     = azurerm_databricks_access_connector.uc_access_connector.name
  # Owned by the metastore admins, not a group with deploy service principles:
  # whoever owns it can reach all data the access connector can
  owner = var.metastore_admins_group_name
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.uc_access_connector.id
  }
}

# Was a metastore data access, which can't be updated after it is created.
# Forget it without deleting, it stays the metastore's root credential.
removed {
  from = databricks_metastore_data_access.uc_access_connector_data_access
  lifecycle {
    destroy = false
  }
}
