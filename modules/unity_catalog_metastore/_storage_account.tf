# Create storage account for Unity Catalog metastore 
resource "azurerm_storage_account" "uc_storage_account" {
  name                     = replace("${var.app_name}-sa-02", "-", "")
  location                 = azurerm_resource_group.uc_rg.location
  resource_group_name      = azurerm_resource_group.uc_rg.name
  tags                     = var.tags
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

# Add container to the storage account
resource "azurerm_storage_container" "uc_storage_account" {
  name                  = "metastore"
  storage_account_id    = azurerm_storage_account.uc_storage_account.id
  container_access_type = "private"
}

# Add permissions from databricks to storage account for data access and file arrivals
locals {
  # Steps 2-4 in https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/azure-managed-identities#--step-2-grant-the-managed-identity-access-to-the-storage-account
  uc_roles = [
    "Storage Blob Data Contributor",   # for normal data access
    "Storage Queue Data Contributor",  # for file arrival triggers
    "EventGrid EventSubscription Contributor",
  ]
}

resource "azurerm_role_assignment" "uc_storage_account" {
  for_each             = toset(local.uc_roles)
  scope                = azurerm_storage_account.uc_storage_account.id
  role_definition_name = each.value
  principal_id         = azurerm_databricks_access_connector.uc_access_connector.identity[0].principal_id
}
