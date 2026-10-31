# ===================================================================
# Serverless Private Endpoint Approvals
# ===================================================================
# Each private endpoint rule of the network connectivity config makes a private
# endpoint connection on its target resource, in Databricks' own subscription,
# which stays Pending until it is approved there. Find each rule's connection
# by its endpoint name and approve it.

locals {
  # Each target resource, and its private endpoint connection type
  ncc_targets = {
    storage   = { id = azurerm_storage_account.px_storage_account.id, type = "Microsoft.Storage/storageAccounts/privateEndpointConnections@2023-05-01" }
    key_vault = { id = azurerm_key_vault.px_key_vault.id, type = "Microsoft.KeyVault/vaults/privateEndpointConnections@2023-07-01" }
    sql       = { id = azurerm_mssql_server.px_sql_server.id, type = "Microsoft.Sql/servers/privateEndpointConnections@2021-11-01" }
  }

  # Each private endpoint rule, and its target
  ncc_rules = {
    storage_dfs   = { target = "storage", endpoint_name = databricks_mws_ncc_private_endpoint_rule.px_ncc_storage_dfs_private_endpoint_rule.endpoint_name }
    storage_blob  = { target = "storage", endpoint_name = databricks_mws_ncc_private_endpoint_rule.px_ncc_storage_blob_private_endpoint_rule.endpoint_name }
    storage_queue = { target = "storage", endpoint_name = databricks_mws_ncc_private_endpoint_rule.px_ncc_storage_queue_private_endpoint_rule.endpoint_name }
    key_vault     = { target = "key_vault", endpoint_name = databricks_mws_ncc_private_endpoint_rule.px_ncc_key_vault_private_endpoint_rule.endpoint_name }
    sql           = { target = "sql", endpoint_name = databricks_mws_ncc_private_endpoint_rule.px_ncc_sql_private_endpoint_rule.endpoint_name }
  }
}

# Give a new rule's connection time to appear on its target
resource "time_sleep" "px_ncc_rules_created" {
  create_duration = "2m"

  depends_on = [
    databricks_mws_ncc_private_endpoint_rule.px_ncc_storage_dfs_private_endpoint_rule,
    databricks_mws_ncc_private_endpoint_rule.px_ncc_storage_blob_private_endpoint_rule,
    databricks_mws_ncc_private_endpoint_rule.px_ncc_storage_queue_private_endpoint_rule,
    databricks_mws_ncc_private_endpoint_rule.px_ncc_key_vault_private_endpoint_rule,
    databricks_mws_ncc_private_endpoint_rule.px_ncc_sql_private_endpoint_rule,
  ]
}

# List the private endpoint connections on each target
data "azapi_resource_list" "px_ncc_connections" {
  for_each               = local.ncc_targets
  type                   = each.value.type
  parent_id              = each.value.id
  response_export_values = ["value"]

  depends_on = [time_sleep.px_ncc_rules_created]
}

# Approve each rule's connection
resource "azapi_update_resource" "px_ncc_approval" {
  for_each = local.ncc_rules
  type     = local.ncc_targets[each.value.target].type
  resource_id = one([
    for connection in data.azapi_resource_list.px_ncc_connections[each.value.target].output.value : connection.id
    if endswith(connection.properties.privateEndpoint.id, "/${each.value.endpoint_name}")
  ])

  body = {
    properties = {
      privateLinkServiceConnectionState = {
        status      = "Approved"
        description = "Databricks serverless (NCC ${databricks_mws_network_connectivity_config.px_ncc.name})"
      }
    }
  }
}
