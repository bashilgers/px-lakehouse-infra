module "lakehouse" {
  source                          = "../../modules/lakehouse"
  subscription_id                 = "138f27a5-cb36-412c-a9f0-9b1ba69e0d55"
  unity_catalog_metastore_id      = "f1c9c23b-ff07-4982-97a8-dfe8b3696412"
  databricks_account_id           = "29c54faf-2e22-47d0-b2bb-f894c93010d2"
  azure_client_id                 = var.azure_client_id
  azure_client_secret             = var.azure_client_secret
  env                             = "p"
  app_name                        = "px-lakehouse"
  location                        = "westeurope"
  vnet_address_space              = "10.3.0.0/16"
  private_subnet_address_prefixes = ["10.3.1.0/24"]
  public_subnet_address_prefixes  = ["10.3.2.0/24"]
  tags = {
    app                 = "px-lakehouse"
    app-sme             = "bas.hilgers@outlook.com"
    app-owner           = "bas.hilgers@outlook.com"
    data-classification = "public"
    criticality         = "1-critical"
    environment         = "prod"
  }
}
