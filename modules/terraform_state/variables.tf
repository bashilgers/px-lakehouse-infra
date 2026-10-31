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
  description = "Azure Subscription ID to deploy the state storage account into"
}

# ===================================================================
# Terraform State
# ===================================================================

variable "containers" {
  type        = list(string)
  description = "Names of the state containers, one per writer"
}

variable "admin_object_ids" {
  type        = list(string)
  description = "Entra ID object IDs of the admin users: the members and owners of the platform admin group"
}

variable "retention_days" {
  type        = number
  description = "Days a deleted state or container can be restored"
  default     = 30
}
