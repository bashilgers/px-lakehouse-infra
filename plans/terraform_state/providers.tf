terraform {
  # State lives in the account this plan creates. Apply it before every other
  # plan. Where the account doesn't exist yet, run bootstrap.sh once: it applies
  # on local state, then moves the state into the account.
  backend "azurerm" {
    subscription_id      = "138f27a5-cb36-412c-a9f0-9b1ba69e0d55"
    resource_group_name  = "px-lakehouse-tfstate-rg"
    storage_account_name = "pxlakehousetfstatesa"
    container_name       = "px-lakehouse-infra"
    key                  = "azure/terraform_state.tfstate"
    use_azuread_auth     = true
  }
}
