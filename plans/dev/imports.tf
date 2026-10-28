# Adopts the catalog container, made by hand for px-lakehouse-data's catalog before it was in Terraform.
# Remove this file once the import has been applied.

import {
  to = module.lakehouse.azurerm_storage_container.container_catalog
  id = "/subscriptions/1ab862af-7c5d-4085-ae0b-af6407432de5/resourceGroups/px-lakehouse-d-rg/providers/Microsoft.Storage/storageAccounts/pxlakehousedsa02/blobServices/default/containers/catalog"
}
