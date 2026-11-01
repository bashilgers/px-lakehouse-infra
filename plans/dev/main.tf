module "lakehouse" {
  source                                   = "../../modules/lakehouse"
  subscription_id                          = "1ab862af-7c5d-4085-ae0b-af6407432de5"
  unity_catalog_metastore_name             = "px-lakehouse-uc-dbr-metastore"
  databricks_account_id                    = "29c54faf-2e22-47d0-b2bb-f894c93010d2"
  env                                      = "d"
  app_name                                 = "px-lakehouse"
  location                                 = "westeurope"
  vnet_address_space                       = "10.1.0.0/16"
  private_subnet_address_prefixes          = ["10.1.1.0/24"]
  public_subnet_address_prefixes           = ["10.1.2.0/24"]
  private_endpoint_subnet_address_prefixes = ["10.1.3.0/24"]
  sql_location                             = "germanywestcentral"
  platform_admins_group_name               = "px-lakehouse-platform-admins"
  azure_databricks_object_id               = "78477c4b-9331-4168-8644-5d13b5e5a7de"
  admins_group_name                        = "px-lakehouse-d-admins"
  metastore_admins_group_name              = "px-lakehouse-metastore-admins"
  default_catalog_name                     = "px_ucc_lakehouse_d"
  allowed_ip_addresses                     = ["83.84.179.42/32", "91.201.164.7/32"]
  sql_writers = [
    "px-lakehouse-d-engineers", # dev only: bundles in development mode run as the developer
  ]
  secret_readers = [
    "px-lakehouse-d-engineers", # dev only: bundles in development mode run as the developer
  ]
  tags = {
    app                 = "px-lakehouse"
    app-sme             = "bas.hilgers@outlook.com"
    app-owner           = "bas.hilgers@outlook.com"
    data-classification = "public"
    criticality         = "4-not-critical"
    environment         = "dev"
  }
}

# Adopt the persona groups that automatic identity management resolves into the
# Databricks account, so a destroy deletes them (modules/lakehouse/_workspace_access.tf)
import {
  for_each = module.lakehouse.persona_group_ids
  to       = module.lakehouse.databricks_group.px_persona[each.key]
  id       = each.value
}
