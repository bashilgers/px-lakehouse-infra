# ===================================================================
# General
# ===================================================================

variable "app_name" {
  type        = string
  description = "Name of application used to prefix resource names"
}

variable "env" {
  type        = string
  description = "Environment abbreviation (development [d], test [t], production [p])"
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
  description = "Azure Subscription ID to deploy the workspace into"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "unity_catalog_metastore_id" {
  type        = string
  description = "The ID of Unity Catalog metastore"
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

# ===================================================================
# Networking
# ===================================================================

variable "vnet_address_space" {
  type        = string
  description = "The address space for the spoke Virtual Network"
}

variable "private_subnet_address_prefixes" {
  type        = list(string)
  description = "Address space for private Databricks subnet"
}

variable "public_subnet_address_prefixes" {
  type        = list(string)
  description = "Address space for public Databricks subnet"
}

variable "service_endpoints" {
  type        = list(string)
  description = "Service endpoints to associate with subnets"
  default = [
    "Microsoft.EventHub",
    "Microsoft.Storage",
    "Microsoft.AzureActiveDirectory",
    "Microsoft.Sql"
  ]
}
