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

variable "metastore_admins_group_name" {
  type        = string
  description = "Name of the humans-only account group that owns the metastore"
}

variable "allowed_ip_addresses" {
  type        = list(string)
  description = "IPv4 addresses (CIDR) of the admins, allowed to reach the metastore's storage account"
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
