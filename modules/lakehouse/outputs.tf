output "workspace_url" {
  value       = "https://${azurerm_databricks_workspace.px_databricks_workspace.workspace_url}"
  description = "URL of the Databricks workspace"
}

output "storage_account_name" {
  value       = azurerm_storage_account.px_storage_account.name
  description = "Name of azure data lake storage account"
}

output "storage_account_id" {
  value       = azurerm_storage_account.px_storage_account.id
  description = "ID of the azure data lake storage account"
}