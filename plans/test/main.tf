module "lakehouse" {
  source                                   = "../../modules/lakehouse"
  subscription_id                          = "3e6ff8b5-2c9b-48bb-b5fb-6b513b3e1dab"
  unity_catalog_metastore_name             = "px-lakehouse-uc-dbr-metastore"
  databricks_account_id                    = "29c54faf-2e22-47d0-b2bb-f894c93010d2"
  env                                      = "t"
  app_name                                 = "px-lakehouse"
  location                                 = "westeurope"
  vnet_address_space                       = "10.2.0.0/16"
  private_subnet_address_prefixes          = ["10.2.1.0/24"]
  public_subnet_address_prefixes           = ["10.2.2.0/24"]
  private_endpoint_subnet_address_prefixes = ["10.2.3.0/24"]
  sql_location                             = "germanywestcentral"
  platform_admins_group_name               = "px-lakehouse-platform-admins"
  azure_databricks_object_id               = "78477c4b-9331-4168-8644-5d13b5e5a7de"
  admins_group_name                        = "px-lakehouse-t-admins"
  metastore_admins_group_name              = "px-lakehouse-metastore-admins"
  default_catalog_name                     = "px_ucc_lakehouse_t"
  allowed_ip_addresses                     = ["83.84.179.42/32", "91.201.164.7/32"]
  tags = {
    app                 = "px-lakehouse"
    app-sme             = "bas.hilgers@outlook.com"
    app-owner           = "bas.hilgers@outlook.com"
    data-classification = "public"
    criticality         = "4-not-critical"
    environment         = "test"
  }
}
