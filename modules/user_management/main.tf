terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  alias = "azurerm_dev"
  subscription_id = var.subscription_id_dev
  features {}
}

provider "azurerm" {
  alias = "azurerm_test"
  subscription_id = var.subscription_id_test
  features {}
}

provider "azurerm" {
  alias = "azurerm_prod"
  subscription_id = var.subscription_id_prod
  features {}
}
