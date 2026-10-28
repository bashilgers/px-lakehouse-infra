# Adopts the access connector's Storage Blob Data Contributor role, created by the removed data_assets
# module, which never had it in this plan's remote state.
# Remove this file once the import has been applied.

import {
  to = module.lakehouse.azurerm_role_assignment.px_access_connector_storage_blob_data_contributor
  id = "/subscriptions/1ab862af-7c5d-4085-ae0b-af6407432de5/resourceGroups/px-lakehouse-d-rg/providers/Microsoft.Storage/storageAccounts/pxlakehousedsa02/providers/Microsoft.Authorization/roleAssignments/a821b8c3-0315-3ec6-b809-4e1cab7102d0"
}
