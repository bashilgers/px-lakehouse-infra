terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "databricks" {
  alias         = "account"
  host          = "https://accounts.azuredatabricks.net"
  account_id    = var.databricks_account_id
  auth_type     = "azure-client-secret"
  client_id     = var.azure_client_id
  client_secret = var.azure_client_secret
}

resource "azurerm_resource_group" "uc_rg" {
  name     = "${var.app_name}-rg"  # only one metastore per region hence no environments
  location = var.location
  tags     = var.tags
}
