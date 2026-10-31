# ===================================================================
# Serverless Private Endpoint Approvals
# ===================================================================
# Each private endpoint rule of the network connectivity config makes a private
# endpoint connection on its target resource, in Databricks' own subscription,
# which stays Pending until it is approved there. Approve each rule's
# connection, found by its endpoint name, once it appears. Only a Pending one:
# Azure SQL refuses any change to a connection that isn't. Runs where Terraform
# runs, with its Azure CLI login.

locals {
  # Each private endpoint rule, and its target resource
  ncc_rules = {
    storage_dfs   = { target = azurerm_storage_account.px_storage_account.id, endpoint_name = databricks_mws_ncc_private_endpoint_rule.px_ncc_storage_dfs_private_endpoint_rule.endpoint_name }
    storage_blob  = { target = azurerm_storage_account.px_storage_account.id, endpoint_name = databricks_mws_ncc_private_endpoint_rule.px_ncc_storage_blob_private_endpoint_rule.endpoint_name }
    storage_queue = { target = azurerm_storage_account.px_storage_account.id, endpoint_name = databricks_mws_ncc_private_endpoint_rule.px_ncc_storage_queue_private_endpoint_rule.endpoint_name }
    key_vault     = { target = azurerm_key_vault.px_key_vault.id, endpoint_name = databricks_mws_ncc_private_endpoint_rule.px_ncc_key_vault_private_endpoint_rule.endpoint_name }
    sql           = { target = azurerm_mssql_server.px_sql_server.id, endpoint_name = databricks_mws_ncc_private_endpoint_rule.px_ncc_sql_private_endpoint_rule.endpoint_name }
  }
}

# Approve each rule's connection, again only if the rule or its target changes
resource "terraform_data" "px_ncc_approval" {
  for_each         = local.ncc_rules
  triggers_replace = [each.value.target, each.value.endpoint_name]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    environment = {
      TARGET      = each.value.target
      ENDPOINT    = each.value.endpoint_name
      DESCRIPTION = "Databricks serverless (NCC ${databricks_mws_network_connectivity_config.px_ncc.name})"
    }
    command = <<-EOT
      set -euo pipefail
      # The connection appears on the target some time after the rule is created
      for attempt in $(seq 1 30); do
        id=$(az network private-endpoint-connection list --id "$TARGET" --query "[?ends_with(properties.privateEndpoint.id, '/$ENDPOINT')].id | [0]" -o tsv 2>/dev/null || true)
        [ -n "$id" ] && break
        sleep 10
      done
      [ -n "$id" ] || { echo "No private endpoint connection $ENDPOINT on $TARGET" >&2; exit 1; }
      status=$(az network private-endpoint-connection show --id "$id" --query properties.privateLinkServiceConnectionState.status -o tsv)
      if [ "$status" = Pending ]; then
        az network private-endpoint-connection approve --id "$id" --description "$DESCRIPTION" -o none
      fi
      echo "$ENDPOINT: $(az network private-endpoint-connection show --id "$id" --query properties.privateLinkServiceConnectionState.status -o tsv)"
    EOT
  }
}
