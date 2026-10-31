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
  }
}

# Shared keys are off on the account, so the provider stays off its data plane:
# containers go through the resource manager (storage_account_id)
provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    storage {
      data_plane_available = false
    }
  }
}

# A resource group of its own, apart from everything the other plans create, so
# tearing those down never takes the state with it
resource "azurerm_resource_group" "tfstate_rg" {
  name     = "${var.app_name}-tfstate-rg"
  location = var.location
  tags     = var.tags
}
