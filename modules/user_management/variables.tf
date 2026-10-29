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
    workspace_id                 = number
    admin_user_names             = list(string) # members of the environment's admin group, beside its deploy service principle
    terraform_state_container_id = string       # only this environment's state, as its deploy service principle can write all of it
    github_repository            = string
    github_subjects              = map(string) # federated credential name => subject
  }))
  description = "Per environment abbreviation: its workspace, its admin users, the storage container of its Terraform state, and the GitHub Actions subjects its deploy service principle trusts"
}

variable "admin_user_names" {
  type        = list(string)
  description = "Databricks account users that are metastore admins and manage the run-as service principles"
}
