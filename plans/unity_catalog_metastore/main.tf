module "unity_catalog_metastore" {
  source                = "../../modules/unity_catalog_metastore"
  subscription_id       = "138f27a5-cb36-412c-a9f0-9b1ba69e0d55"
  databricks_account_id = "29c54faf-2e22-47d0-b2bb-f894c93010d2"
  azure_client_id       = var.azure_client_id
  azure_client_secret   = var.azure_client_secret
  app_name              = "px-lakehouse-uc"
  location              = "westeurope"
  tags = {
    app                 = "px-lakehouse"
    app-sme             = "bas.hilgers@outlook.com"
    app-owner           = "bas.hilgers@outlook.com"
    data-classification = "public"
    criticality         = "4-not-critical"
    environment         = "prod"
  }
}
