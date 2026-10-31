# ===================================================================
# Terraform State Storage Account
# ===================================================================
# Holds the Terraform state of every root in this repository and in
# px-lakehouse-data. Entra ID only: with shared keys off, reading a state takes a
# data role on the account or its container, not just a role on the subscription.

resource "azurerm_storage_account" "tfstate" {
  name                            = replace("${var.app_name}-tfstate-sa", "-", "")
  resource_group_name             = azurerm_resource_group.tfstate_rg.name
  location                        = azurerm_resource_group.tfstate_rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  tags                            = var.tags

  # Every write keeps the state it replaces as a version, and a deleted state or
  # container can be restored within the retention
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = var.retention_days
    }
    container_delete_retention_policy {
      days = var.retention_days
    }
  }

  # Holds the state of every root
  lifecycle {
    prevent_destroy = true
  }
}

# A container per writer, as a deploy identity can write all of its container
# (user_management gives each its role)
resource "azurerm_storage_container" "tfstate" {
  for_each              = toset(var.containers)
  name                  = each.key
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}

# Let the admins read and write every state, through their group
resource "azurerm_role_assignment" "tfstate_platform_admins" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_group.px_platform_admins.object_id
  principal_type       = "Group"
}
