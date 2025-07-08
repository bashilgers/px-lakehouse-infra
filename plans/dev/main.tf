module "lakehouse" {
  source                          = "../../modules/lakehouse"
  subscription_id                 = "1ab862af-7c5d-4085-ae0b-af6407432de5"
  unity_catalog_metastore_id      = "f1c9c23b-ff07-4982-97a8-dfe8b3696412"
  databricks_account_id           = "29c54faf-2e22-47d0-b2bb-f894c93010d2"
  azure_client_id                 = var.azure_client_id
  azure_client_secret             = var.azure_client_secret
  env                             = "d"
  app_name                        = "px-lakehouse"
  location                        = "westeurope"
  vnet_address_space              = "10.1.0.0/16"
  private_subnet_address_prefixes = ["10.1.1.0/24"]
  public_subnet_address_prefixes  = ["10.1.2.0/24"]
  tags = {
    app                 = "px-lakehouse"
    app-sme             = "bas.hilgers@outlook.com"
    app-owner           = "bas.hilgers@outlook.com"
    data-classification = "public"
    criticality         = "4-not-critical"
    environment         = "dev"
  }
}

module "data_assets" {
  source                     = "../../modules/data_assets"
  subscription_id            = "1ab862af-7c5d-4085-ae0b-af6407432de5"
  unity_catalog_metastore_id = "f1c9c23b-ff07-4982-97a8-dfe8b3696412"
  app_name                   = "px-lakehouse"
  env                        = "d"
  catalog_name               = "dev"
  catalog_owner              = "bas.hilgers@outlook.com"
  storage_account_name       = module.lakehouse.storage_account_name
  storage_account_id         = module.lakehouse.storage_account_id
  access_connector_name      = "px-lakehouse-uc-dbr-connector"
  access_connector_id        = "4cf1f221-1d2f-4537-bca6-8c8d07a35095"
  providers = {
    databricks = databricks.workspace
  }
}