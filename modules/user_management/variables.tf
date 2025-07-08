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
