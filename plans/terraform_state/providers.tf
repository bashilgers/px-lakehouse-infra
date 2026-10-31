terraform {
  # State lives in the account this plan creates. Apply it before every other
  # plan. Where the account doesn't exist yet, the first apply runs on local
  # state: comment out this backend, `terraform init` and `terraform apply`, then
  # restore it and `terraform init -migrate-state`. The admins' data role can take
  # a few minutes to apply before the migration gets in.
  backend "azurerm" {
    subscription_id      = "138f27a5-cb36-412c-a9f0-9b1ba69e0d55"
    resource_group_name  = "px-lakehouse-tfstate-rg"
    storage_account_name = "pxlakehousetfstatesa"
    container_name       = "px-lakehouse-infra"
    key                  = "azure/terraform_state.tfstate"
    use_azuread_auth     = true
  }
}
