variable "azure_client_id" {
  type      = string
  sensitive = true
}
variable "azure_client_secret" {
  type      = string
  sensitive = true
}
variable "teardown" {
  type        = bool
  default     = false
  description = "Set for the apply before a destroy, and for the destroy (lakehouse module)"
}
