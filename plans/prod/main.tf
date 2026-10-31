module "lakehouse" {
  source                                   = "../../modules/lakehouse"
  subscription_id                          = "138f27a5-cb36-412c-a9f0-9b1ba69e0d55"
  unity_catalog_metastore_name             = "px-lakehouse-uc-dbr-metastore"
  databricks_account_id                    = "29c54faf-2e22-47d0-b2bb-f894c93010d2"
  azure_client_id                          = var.azure_client_id
  azure_client_secret                      = var.azure_client_secret
  env                                      = "p"
  app_name                                 = "px-lakehouse"
  location                                 = "westeurope"
  vnet_address_space                       = "10.3.0.0/16"
  private_subnet_address_prefixes          = ["10.3.1.0/24"]
  public_subnet_address_prefixes           = ["10.3.2.0/24"]
  private_endpoint_subnet_address_prefixes = ["10.3.3.0/24"]
  sql_location                             = "germanywestcentral"
  platform_admins_group_name               = "px-lakehouse-platform-admins"
  azure_databricks_object_id               = "78477c4b-9331-4168-8644-5d13b5e5a7de"
  admins_group_name                        = "px-lakehouse-p-admins"
  metastore_admins_group_name              = "px-lakehouse-metastore-admins"
  default_catalog_name                     = "px_ucc_phoenix_p"
  allowed_ip_addresses                     = ["83.84.179.42/32", "91.201.164.7/32"]
  # No engineers in prod: they build in dev and test, and nobody reads all of prod's data
  personas = ["readers", "support"]
  tags = {
    app                 = "px-lakehouse"
    app-sme             = "bas.hilgers@outlook.com"
    app-owner           = "bas.hilgers@outlook.com"
    data-classification = "public"
    criticality         = "1-critical"
    environment         = "prod"
  }
}
