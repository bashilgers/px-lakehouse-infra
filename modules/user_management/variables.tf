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
    admin_user_names             = list(string)     # members of the environment's admin group, beside its deploy service principal
    terraform_state_container_id = optional(string) # only this environment's state, as its deploy service principal can write all of it; null for none yet
    github_repository            = string           # owner/name
    github_environment           = string           # the GitHub environment that deploys it, e.g. dev
    github_subjects              = map(string)      # federated credential name => subject
    personas                     = optional(list(string), ["engineers", "readers", "support"])
  }))
  description = "Per environment abbreviation: its admin users, the storage container of its Terraform state, its GitHub environment and the GitHub Actions subjects its deploy service principal trusts, and its persona groups (of local.personas in _persona_groups.tf)"
}

variable "admin_user_names" {
  type        = list(string)
  description = "Databricks account users that are metastore admins, and so manage the run-as service principals and the secret scopes"
}

variable "group_owner_object_ids" {
  type        = list(string)
  description = "Entra ID object IDs of the users who own the persona groups and manage their membership in Entra ID"
}

variable "github_owner" {
  type        = string
  description = "GitHub account that owns the repositories in environments; the GitHub provider's token (GITHUB_TOKEN) must administer them"
}

variable "group_member_object_ids" {
  type        = list(string)
  default     = []
  description = "Entra ID object IDs of the users who are the first members of the persona and key vault manager groups, when they are created; after that, membership is managed in Entra ID"
}
