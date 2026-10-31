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
    admin_user_names             = list(string)     # members of the environment's admin group, beside its deploy service principle
    terraform_state_container_id = optional(string) # only this environment's state, as its deploy service principle can write all of it; null for none yet
    github_repository            = string
    github_subjects              = map(string) # federated credential name => subject
    personas                     = optional(list(string), ["engineers", "readers", "support"])
  }))
  description = "Per environment abbreviation: its admin users, the storage container of its Terraform state, the GitHub Actions subjects its deploy service principle trusts, and its persona groups (of local.personas in _persona_groups.tf)"
}

variable "admin_user_names" {
  type        = list(string)
  description = "Databricks account users that are metastore admins, and so manage the run-as service principles and the secret scopes"
}

variable "group_owner_object_ids" {
  type        = list(string)
  description = "Entra ID object IDs of the users who own the persona groups and manage their membership in Entra ID"
}
