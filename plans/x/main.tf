module "lakehouse" {
  source                                   = "../../modules/lakehouse"
  subscription_id                          = "1ab862af-7c5d-4085-ae0b-af6407432de5"
  unity_catalog_metastore_name             = "px-lakehouse-uc-dbr-metastore"
  databricks_account_id                    = "29c54faf-2e22-47d0-b2bb-f894c93010d2"
  azure_client_id                          = var.azure_client_id
  azure_client_secret                      = var.azure_client_secret
  env                                      = "x"
  app_name                                 = "px-lakehouse"
  location                                 = "westeurope"
  vnet_address_space                       = "10.9.0.0/16"
  private_subnet_address_prefixes          = ["10.9.1.0/24"]
  public_subnet_address_prefixes           = ["10.9.2.0/24"]
  private_endpoint_subnet_address_prefixes = ["10.9.3.0/24"]
  sql_location                             = "germanywestcentral"
  sql_entra_admin_login                    = "bas.hilgers@outlook.com"
  sql_entra_admin_object_id                = "c0071a22-3f84-4337-ad09-871f52c3a1ba"
  azure_databricks_object_id               = "78477c4b-9331-4168-8644-5d13b5e5a7de"
  admins_group_name                        = "px-lakehouse-x-admins"
  metastore_admins_group_name              = "px-lakehouse-metastore-admins"
  workspace_allowed_ip_addresses           = ["83.84.179.42/32", "91.201.164.7/32"]
  tags = {
    app                 = "px-lakehouse"
    app-sme             = "bas.hilgers@outlook.com"
    app-owner           = "bas.hilgers@outlook.com"
    data-classification = "public"
    criticality         = "4-not-critical"
    environment         = "x"
  }
}
