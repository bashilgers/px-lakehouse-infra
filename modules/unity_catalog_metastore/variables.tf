variable "app_name" {
  type        = string
  description = "Name of application used to prefix resource names"
}

variable "location" {
  type        = string
  description = "The Azure region of the metastore, the same as the workspaces'"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "metastore_admins_group_name" {
  type        = string
  description = "Name of the humans-only account group that owns the metastore"
}
