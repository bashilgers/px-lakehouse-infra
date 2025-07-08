variable "app_name" {
  type        = string
  description = "Name of application used to prefix resource names"
}

variable "env" {
  type        = string
  description = "Environment abbreviation (development [d], test [t], production [p])"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID to deploy the workspace into"
}

variable "unity_catalog_metastore_id" {
  type        = string
  description = "The ID of Unity Catalog metastore"
}

variable "catalog_name" {
  type        = string
  description = "Name of the catalog to create in Unity Catalog"
}

variable "catalog_owner" {
  type        = string
  description = "Service principal or user to assign as owner of the catalog"
}

variable "storage_account_name" {
  type        = string
  description = "The name of azure data lake storage account"
}

variable "storage_account_id" {
  type        = string
  description = "The ID of azure data lake storage account"
}

variable "access_connector_name" {
  type        = string
  description = "The name of the access connector"
}

variable "access_connector_id" {
  type        = string
  description = "The id of the access connector"
}