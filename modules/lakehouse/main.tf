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
      version = ">=1.52.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.12"
    }
  }
}

provider "databricks" {
  alias         = "account"
  host          = "https://accounts.azuredatabricks.net"
  account_id    = var.databricks_account_id
  client_id     = var.azure_client_id
  client_secret = var.azure_client_secret
}

provider "databricks" {
  alias = "workspace"
  host  = "https://${azurerm_databricks_workspace.px_databricks_workspace.workspace_url}"
}

provider "azapi" {
  subscription_id = var.subscription_id
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

resource "azurerm_resource_group" "px_rg" {
  name     = "${var.app_name}-${var.env}-rg"
  location = var.location
  tags     = var.tags
}

data "azurerm_client_config" "current" {}
