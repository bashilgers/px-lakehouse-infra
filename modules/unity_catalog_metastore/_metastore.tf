# Register metastore for region in Unity Catalog 
resource "databricks_metastore" "uc_metastore" {
  provider     = databricks.account
  name         = "${var.app_name}-dbr-metastore"
  region       = azurerm_resource_group.uc_rg.location
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/", azurerm_storage_container.uc_storage_account.name, azurerm_storage_account.uc_storage_account.name)
  # Owned by a humans-only group, whose members are the metastore admins
  owner = var.metastore_admins_group_name

  lifecycle {
    # Set outside this resource: the root credential is the data access below,
    # and the token lifetime is left at the account's default
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

# Make the access connector the metastore's root credential, through the
# account API, so this plan needs no workspace. Owned by the metastore admins,
# not a group with deploy service principles: whoever owns it can reach all
# data the access connector can. The provider can't change it once created
# ("doesn't support update"), so its owner is set here from the start.
resource "databricks_metastore_data_access" "uc_root_credential" {
  provider     = databricks.account
  metastore_id = databricks_metastore.uc_metastore.id
  name         = azurerm_databricks_access_connector.uc_access_connector.name
  owner        = var.metastore_admins_group_name
  is_default   = true

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.uc_access_connector.id
  }
}
