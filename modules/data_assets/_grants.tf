# ===================================================================
# Connection Storage Blob Data Contributor Access
# ===================================================================

resource "azurerm_role_assignment" "ext_storage" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.access_connector_id
}

# ===================================================================
# Set Catalog Owner
# ===================================================================

resource "databricks_grants" "catalog_grants" {
  depends_on = [databricks_catalog.catalog]
  catalog    = "${var.catalog_name}"
  grant {
    principal  = var.catalog_owner
    privileges = ["ALL_PRIVILEGES"]
  }
}

# ===================================================================
# Set Schema Owner
# ===================================================================

resource "databricks_grants" "exloc_landing_grants" {
  depends_on = [databricks_external_location.exloc_adls_landing]
  external_location = databricks_external_location.exloc_adls_landing.id
  grant {
    principal  = var.catalog_owner
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "exloc_bronze_grants" {
  depends_on = [databricks_external_location.exloc_adls_bronze]
  external_location = databricks_external_location.exloc_adls_bronze.id
  grant {
    principal  = var.catalog_owner
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "exloc_silver_grants" {
  depends_on = [databricks_external_location.exloc_adls_silver]
  external_location = databricks_external_location.exloc_adls_silver.id
  grant {
    principal  = var.catalog_owner
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "exloc_gold_grants" {
  depends_on = [databricks_external_location.exloc_adls_gold]
  external_location = databricks_external_location.exloc_adls_gold.id
  grant {
    principal  = var.catalog_owner
    privileges = ["ALL_PRIVILEGES"]
  }
}
