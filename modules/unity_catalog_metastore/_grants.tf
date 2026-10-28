# ===================================================================
# Metastore Grants for Admin Group
# ===================================================================
# The admin group owns what Terraform creates in Unity Catalog, so it needs to
# create catalogs, external locations and connections.

# Let admin group create catalogs, external locations and connections
resource "databricks_grant" "uc_metastore_admins" {
  provider   = databricks.workspace
  metastore  = databricks_metastore.uc_metastore.id
  principal  = var.admins_group_name
  privileges = ["CREATE_CATALOG", "CREATE_CONNECTION", "CREATE_EXTERNAL_LOCATION"]
}

# Let admin group create external locations on the access connector
resource "databricks_grant" "uc_access_connector_admins" {
  provider           = databricks.workspace
  storage_credential = databricks_metastore_data_access.uc_access_connector_data_access.name
  principal          = var.admins_group_name
  privileges         = ["CREATE_EXTERNAL_LOCATION"]
}
