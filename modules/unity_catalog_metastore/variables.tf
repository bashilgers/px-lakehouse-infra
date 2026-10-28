# ===================================================================
# General
# ===================================================================

variable "app_name" {
  type        = string
  description = "Name of application used to prefix resource names"
}

variable "location" {
  type        = string
  description = "The location of Azure Data center for the resources"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to attach to resources"
  default     = {}
}

# ===================================================================
# Azure Identifiers
# ===================================================================

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID to deploy the workspace into (pu)"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "workspace_host" {
  type        = string
  description = "URL of a workspace attached to the metastore, through which metastore grants are made"
}

variable "admins_group_name" {
  type        = string
  description = "Name of the account group that administers Unity Catalog objects"
}

# ===================================================================
# Service Principles
# ===================================================================

variable "azure_client_id" {
  type        = string
  description = "Application ID of the service principle registered in Azure"
}

variable "azure_client_secret" {
  type        = string
  description = "Application secret of the service principle registered in Databricks Accounts"
}
