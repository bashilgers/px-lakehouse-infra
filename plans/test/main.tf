module "lakehouse" {
  source                                   = "../../modules/lakehouse"
  subscription_id                          = "3e6ff8b5-2c9b-48bb-b5fb-6b513b3e1dab"
  unity_catalog_metastore_id               = "c4ffc048-f9f8-4401-a393-238a3c29fae0"
  databricks_account_id                    = "29c54faf-2e22-47d0-b2bb-f894c93010d2"
  azure_client_id                          = var.azure_client_id
  azure_client_secret                      = var.azure_client_secret
  env                                      = "t"
  app_name                                 = "px-lakehouse"
  location                                 = "westeurope"
  vnet_address_space                       = "10.2.0.0/16"
  private_subnet_address_prefixes          = ["10.2.1.0/24"]
  public_subnet_address_prefixes           = ["10.2.2.0/24"]
  private_endpoint_subnet_address_prefixes = ["10.2.3.0/24"]
  sql_location                             = "germanywestcentral"
  sql_entra_admin_login                    = "bas.hilgers@outlook.com"
  sql_entra_admin_object_id                = "c0071a22-3f84-4337-ad09-871f52c3a1ba"
  azure_databricks_object_id               = "78477c4b-9331-4168-8644-5d13b5e5a7de"
  admins_group_name                        = "px-lakehouse-t-admins"
  metastore_admins_group_name              = "px-lakehouse-metastore-admins"
  workspace_allowed_ip_addresses           = ["83.84.179.42/32", "91.201.164.7/32"]
  sql_writers = [
    "59397832-0061-49d0-af97-e5c1f170ba54", # px-lakehouse-t-run-sp, the run-as identity
  ]
  tags = {
    app                 = "px-lakehouse"
    app-sme             = "bas.hilgers@outlook.com"
    app-owner           = "bas.hilgers@outlook.com"
    data-classification = "public"
    criticality         = "4-not-critical"
    environment         = "test"
  }
}
