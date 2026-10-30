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
# Unity Catalog
# ===================================================================

variable "admins_group_name" {
  type        = string
  description = "Name of the environment's admin group, which owns its Unity Catalog objects (px-lakehouse-<env>-admins)"
}

variable "metastore_admins_group_name" {
  type        = string
  description = "Name of the humans-only account group that owns the metastore"
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

variable "private_endpoint_subnet_address_prefixes" {
  type        = list(string)
  description = "Address space for private endpoint subnet"
}

variable "workspace_allowed_ip_addresses" {
  type        = list(string)
  description = "IPv4 addresses (CIDR) allowed to reach the Databricks workspace UI and API"
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

# ===================================================================
# Key Vault
# ===================================================================

variable "azure_databricks_object_id" {
  type        = string
  description = "Object ID of the AzureDatabricks enterprise application (app ID 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d) in the tenant"
}

# ===================================================================
# Azure SQL
# ===================================================================

variable "sql_location" {
  type        = string
  description = "The location of Azure Data center for the SQL server (westeurope refuses new SQL servers)"
}

variable "sql_entra_admin_login" {
  type        = string
  description = "Login name of the Entra ID user that administers the SQL server"
}

variable "sql_entra_admin_object_id" {
  type        = string
  description = "Object ID of the Entra ID user that administers the SQL server"
}
