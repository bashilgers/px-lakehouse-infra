# ===================================================================
# Catalog
# ===================================================================

resource "databricks_catalog" "catalog" {
  metastore_id  = var.unity_catalog_metastore_id
  name          = "${var.catalog_name}"
  force_destroy = true
}

# ===================================================================
# External Location - Landing
# ===================================================================

# Register landing external location
resource "databricks_external_location" "exloc_adls_landing" {
depends_on        = [azurerm_role_assignment.ext_storage]
  name            = "${var.app_name}-${var.env}-exloc-landing"
  url             = format("abfss://landing@%s.dfs.core.windows.net/", var.storage_account_name)
  credential_name = var.access_connector_name
  comment         = "External location connection to landing data and model assets"
}

# Create schema for landing
resource "databricks_schema" "schema_landing" {
  depends_on    = [databricks_catalog.catalog, databricks_grants.exloc_landing_grants]
  catalog_name  = databricks_catalog.catalog.name
  name          = "landing"
  owner         = var.catalog_owner
  comment       = "Schema for landing data and model assets"
  storage_root  = format("abfss://landing@%s.dfs.core.windows.net/", var.storage_account_name)
}

# ===================================================================
# External Location - Bronze
# ===================================================================

# Register bronze external location
resource "databricks_external_location" "exloc_adls_bronze" {
depends_on        = [azurerm_role_assignment.ext_storage]
  name            = "${var.app_name}-${var.env}-exloc-bronze"
  url             = format("abfss://bronze@%s.dfs.core.windows.net/", var.storage_account_name)
  credential_name = var.access_connector_name
  comment         = "External location connection to bronze data and model assets"
}

# Create schema for bronze
resource "databricks_schema" "schema_bronze" {
  depends_on    = [databricks_catalog.catalog, databricks_grants.exloc_bronze_grants]
  catalog_name  = databricks_catalog.catalog.name
  name          = "bronze"
  owner         = var.catalog_owner
  comment       = "Schema for bronze data and model assets"
  storage_root  = format("abfss://bronze@%s.dfs.core.windows.net/", var.storage_account_name)
}

# ===================================================================
# External Location - Silver
# ===================================================================

# Register silver external location
resource "databricks_external_location" "exloc_adls_silver" {
depends_on        = [azurerm_role_assignment.ext_storage]
  name            = "${var.app_name}-${var.env}-exloc-silver"
  url             = format("abfss://silver@%s.dfs.core.windows.net/", var.storage_account_name)
  credential_name = var.access_connector_name
  comment         = "External location connection to silver data and model assets"
}

# Create schema for silver
resource "databricks_schema" "schema_silver" {
  depends_on    = [databricks_catalog.catalog, databricks_grants.exloc_silver_grants]
  catalog_name  = databricks_catalog.catalog.name
  name          = "silver"
  owner         = var.catalog_owner
  comment       = "Schema for silver data and model assets"
  storage_root  = format("abfss://silver@%s.dfs.core.windows.net/", var.storage_account_name)
}

# ===================================================================
# External Location - Gold
# ===================================================================

# Register gold external location
resource "databricks_external_location" "exloc_adls_gold" {
depends_on        = [azurerm_role_assignment.ext_storage]
  name            = "${var.app_name}-${var.env}-exloc-gold"
  url             = format("abfss://gold@%s.dfs.core.windows.net/", var.storage_account_name)
  credential_name = var.access_connector_name
  comment         = "External location connection to gold data and model assets"
}

# Create schema for gold
resource "databricks_schema" "schema_gold" {
  depends_on    = [databricks_catalog.catalog, databricks_grants.exloc_gold_grants]
  catalog_name  = databricks_catalog.catalog.name
  name          = "gold"
  owner         = var.catalog_owner
  comment       = "Schema for gold data and model assets"
  force_destroy = true
  storage_root  = format("abfss://gold@%s.dfs.core.windows.net/", var.storage_account_name)
}
