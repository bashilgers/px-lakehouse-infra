variable "app_name" {
  type        = string
  description = "Name of application used to prefix resource names"
}

variable "subscription_id_dev" {
  type        = string
  description = "Azure Subscription ID of development environment"
}

variable "subscription_id_test" {
  type        = string
  description = "Azure Subscription ID of test environment"
}

variable "subscription_id_prod" {
  type        = string
  description = "Azure Subscription ID of production environment"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "environments" {
  type = map(object({
    workspace_id      = number
    github_repository = string
    github_subjects   = map(string) # federated credential name => subject
  }))
  description = "Per environment abbreviation, its workspace and the GitHub Actions subjects its deploy service principle trusts"
}

variable "terraform_state_container_id" {
  type        = string
  description = "Resource ID of the storage container that holds the Terraform state the deploy service principles use"
}

variable "admin_user_names" {
  type        = list(string)
  description = "Databricks account users that are members of the admin group"
}
