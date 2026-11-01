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

output "adls_connector_id" {
  value       = azurerm_databricks_access_connector.px_dbr_adls_connector.id
  description = "ID of the environment's dbr-adls-connector, for its storage credential"
}

output "sqlsrv_connector_principal_id" {
  value       = azurerm_databricks_access_connector.px_sql_connector.identity[0].principal_id
  description = "Object ID of the dbr-sqlsrv-connector's managed identity, for its user in the database"
}

output "persona_group_ids" {
  value       = { for persona, group in data.databricks_account_iam_external_group_v2.px_persona : persona => group.internal_id }
  description = "The persona groups resolved into the Databricks account, by persona: the import IDs of databricks_group.px_persona"
}
