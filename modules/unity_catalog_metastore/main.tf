terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>5.0" # its state is 5.x; the other plans are on 4.x
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.140.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}

resource "azurerm_resource_group" "uc_rg" {
  name     = "${var.app_name}-rg" # only one metastore per region hence no environments
  location = var.location
  tags     = var.tags
}
