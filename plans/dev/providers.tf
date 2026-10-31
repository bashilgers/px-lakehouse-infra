terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.52.0"
    }
  }

  # State lives beside px-lakehouse-data's, in the PROD subscription's state account
  backend "azurerm" {
    subscription_id      = "138f27a5-cb36-412c-a9f0-9b1ba69e0d55"
    resource_group_name  = "px-lakehouse-tfstate-rg"
    storage_account_name = "pxlakehousetfstatesa"
    container_name       = "px-lakehouse-infra"
    key                  = "azure/dev/lakehouse.tfstate"
    use_azuread_auth     = true
  }
}
