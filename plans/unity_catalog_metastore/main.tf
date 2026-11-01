module "unity_catalog_metastore" {
  source                      = "../../modules/unity_catalog_metastore"
  databricks_account_id       = "29c54faf-2e22-47d0-b2bb-f894c93010d2"
  metastore_admins_group_name = "px-lakehouse-metastore-admins"
  app_name                    = "px-lakehouse-uc"
  location                    = "westeurope"
}
