# ===================================================================
# Key Vault Manager Groups in Entra ID (per environment)
# ===================================================================
# Manage the secrets in the environment's key vault (lakehouse) and renew
# them before they expire, such as the SQL identity's client secret, which is
# made by hand. Membership is managed in Entra ID, not here. Not in
# Databricks: the secrets reach it through the workspace's secret scope.

# Create security group in entra id per environment
resource "azuread_group" "px_keyvault_managers" {
  for_each                = var.environments
  display_name            = "${var.app_name}-${each.key}-kv-managers"
  description             = "Key vault managers of ${var.app_name}-${each.key}: manage its key vault's secrets and renew them"
  security_enabled        = true
  prevent_duplicate_names = true
  owners                  = var.group_owner_object_ids
  members                 = var.group_member_object_ids

  # Membership is managed in Entra ID, not in this code: the members above are
  # only the first ones
  lifecycle {
    ignore_changes = [members]
  }
}
