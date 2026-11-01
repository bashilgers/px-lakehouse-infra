terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.140.0"
    }
  }
}

provider "azurerm" {
  alias           = "azurerm_dev"
  subscription_id = var.subscription_id_dev
  features {}
}

provider "azurerm" {
  alias           = "azurerm_test"
  subscription_id = var.subscription_id_test
  features {}
}

provider "azurerm" {
  alias           = "azurerm_prod"
  subscription_id = var.subscription_id_prod
  features {}
}

provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}
