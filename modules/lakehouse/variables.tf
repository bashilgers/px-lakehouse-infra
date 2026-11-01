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

variable "unity_catalog_metastore_name" {
  type        = string
  description = "The name of the region's Unity Catalog metastore (unity_catalog_metastore)"
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
  description = "Name of the humans-only account group that owns the metastore, and manages the secret scope"
}

variable "personas" {
  type        = list(string)
  default     = ["engineers", "readers", "support"]
  description = "The environment's persona groups (user_management), each px-lakehouse-<env>-<persona>"
}

variable "default_catalog_name" {
  type        = string
  description = "Catalog that unqualified table names in the workspace point at: the environment's catalog, which px-lakehouse-data makes"
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

variable "allowed_ip_addresses" {
  type        = list(string)
  description = "IPv4 addresses (CIDR) of the admins, allowed to reach the Databricks workspace UI and API, the storage account and the key vault"
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

variable "secret_readers" {
  type        = list(string)
  default     = []
  description = "Principals beside the run-as service principal with READ on the secret scope: service principals by application ID, groups by name"
}

# ===================================================================
# Azure SQL
# ===================================================================

variable "sql_location" {
  type        = string
  description = "The location of Azure Data center for the SQL server (westeurope refuses new SQL servers)"
}

variable "platform_admins_group_name" {
  type        = string
  description = "Name of the Entra ID group of the admin users (terraform_state), which administers the SQL server"
}

variable "sql_writers" {
  type        = list(string)
  default     = []
  description = "Principals beside the run-as service principal with ACCESS on the SQL service credential, to write to the database as its identity: service principals by application ID, groups by name"
}
