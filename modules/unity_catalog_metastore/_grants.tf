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
