# ===================================================================
# Metastore Grants for Environment Admin Groups
# ===================================================================
# Each environment's admin group owns what px-lakehouse-data creates in that
# environment, so it needs to create catalogs, external locations and
# connections. External locations also take CREATE_EXTERNAL_LOCATION on the
# environment's own storage credential (lakehouse module).

# Let each environment's admin group create catalogs, external locations and connections
resource "databricks_grant" "uc_metastore_env_admins" {
  for_each   = toset(var.env_admins_group_names)
  provider   = databricks.workspace
  metastore  = databricks_metastore.uc_metastore.id
  principal  = each.key
  privileges = ["CREATE_CATALOG", "CREATE_CONNECTION", "CREATE_EXTERNAL_LOCATION"]
}

# ===================================================================
# Metastore Grants for Admin Group (being phased out)
# ===================================================================
# The admin group of every environment, until px-lakehouse-data uses the
# environment admin groups above. Remove both grants with it (user_management).

# Let admin group create catalogs, external locations and connections
resource "databricks_grant" "uc_metastore_admins" {
  provider   = databricks.workspace
  metastore  = databricks_metastore.uc_metastore.id
  principal  = var.admins_group_name
  privileges = ["CREATE_CATALOG", "CREATE_CONNECTION", "CREATE_EXTERNAL_LOCATION"]
}

# Let admin group create external locations on the access connector, which the
# dev external locations use until they move to the environment's own
resource "databricks_grant" "uc_access_connector_admins" {
  provider           = databricks.workspace
  storage_credential = databricks_storage_credential.uc_storage_credential.id
  principal          = var.admins_group_name
  privileges         = ["CREATE_EXTERNAL_LOCATION"]
}
