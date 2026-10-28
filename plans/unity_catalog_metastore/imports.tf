# Adopts the metastore resources that existed before this plan had a remote state.
# Remove this file once the import has been applied.

import {
  to = module.unity_catalog_metastore.azurerm_resource_group.uc_rg
  id = "/subscriptions/138f27a5-cb36-412c-a9f0-9b1ba69e0d55/resourceGroups/px-lakehouse-uc-rg"
}

import {
  to = module.unity_catalog_metastore.azurerm_storage_account.uc_storage_account
  id = "/subscriptions/138f27a5-cb36-412c-a9f0-9b1ba69e0d55/resourceGroups/px-lakehouse-uc-rg/providers/Microsoft.Storage/storageAccounts/pxlakehouseucsa02"
}

import {
  to = module.unity_catalog_metastore.azurerm_storage_container.uc_storage_account
  id = "/subscriptions/138f27a5-cb36-412c-a9f0-9b1ba69e0d55/resourceGroups/px-lakehouse-uc-rg/providers/Microsoft.Storage/storageAccounts/pxlakehouseucsa02/blobServices/default/containers/metastore"
}

import {
  to = module.unity_catalog_metastore.azurerm_role_assignment.uc_storage_account["Storage Blob Data Contributor"]
  id = "/subscriptions/138f27a5-cb36-412c-a9f0-9b1ba69e0d55/resourceGroups/px-lakehouse-uc-rg/providers/Microsoft.Storage/storageAccounts/pxlakehouseucsa02/providers/Microsoft.Authorization/roleAssignments/06c00f65-c6a8-e329-a057-0eec420bb7b4"
}

import {
  to = module.unity_catalog_metastore.azurerm_role_assignment.uc_storage_account["Storage Queue Data Contributor"]
  id = "/subscriptions/138f27a5-cb36-412c-a9f0-9b1ba69e0d55/resourceGroups/px-lakehouse-uc-rg/providers/Microsoft.Storage/storageAccounts/pxlakehouseucsa02/providers/Microsoft.Authorization/roleAssignments/98d94ed6-2971-b16f-1a3e-880dae60a918"
}

import {
  to = module.unity_catalog_metastore.azurerm_role_assignment.uc_storage_account["EventGrid EventSubscription Contributor"]
  id = "/subscriptions/138f27a5-cb36-412c-a9f0-9b1ba69e0d55/resourceGroups/px-lakehouse-uc-rg/providers/Microsoft.Storage/storageAccounts/pxlakehouseucsa02/providers/Microsoft.Authorization/roleAssignments/94b31b2f-0c46-01f5-9a82-ad482b7a2e98"
}

import {
  to = module.unity_catalog_metastore.databricks_metastore.uc_metastore
  id = "f1c9c23b-ff07-4982-97a8-dfe8b3696412"
}

import {
  to = module.unity_catalog_metastore.azurerm_databricks_access_connector.uc_access_connector
  id = "/subscriptions/138f27a5-cb36-412c-a9f0-9b1ba69e0d55/resourceGroups/px-lakehouse-uc-rg/providers/Microsoft.Databricks/accessConnectors/px-lakehouse-uc-dbr-connector"
}

import {
  to = module.unity_catalog_metastore.databricks_metastore_data_access.uc_access_connector_data_access
  id = "f1c9c23b-ff07-4982-97a8-dfe8b3696412|px-lakehouse-uc-dbr-connector"
}

import {
  to = module.unity_catalog_metastore.databricks_grant.uc_metastore_admins
  id = "metastore/f1c9c23b-ff07-4982-97a8-dfe8b3696412/px-lakehouse-admins"
}

import {
  to = module.unity_catalog_metastore.databricks_grant.uc_access_connector_admins
  id = "storage_credential/px-lakehouse-uc-dbr-connector/px-lakehouse-admins"
}
