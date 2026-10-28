# Adopts the identities that existed before this plan had a remote state.
# Remove this file once the import has been applied.

import {
  to = module.user_management.azuread_application_registration.px_sp
  id = "/applications/26eb7873-e7d0-429f-9ab0-c51af446f212"
}

import {
  to = module.user_management.azuread_service_principal.px_sp
  id = "/servicePrincipals/77aa3c30-b723-40af-b251-3ee7c1c5ff8c"
}

import {
  to = module.user_management.azuread_directory_role.global_admin
  id = "/directoryRoles/6308beab-e0fc-4171-8733-30454486dca8"
}

import {
  to = module.user_management.azuread_directory_role_assignment.global_admin
  id = "/roleManagement/directory/roleAssignments/lAPpYvVpN0KRkAEhdxReEDA8qncjt69AslE-58HF_4w-1"
}

import {
  to = module.user_management.azurerm_role_assignment.sp_contributor_dev
  id = "/subscriptions/1ab862af-7c5d-4085-ae0b-af6407432de5/providers/Microsoft.Authorization/roleAssignments/aec3bdbb-e40d-ca2e-5423-a58207c887b5"
}

import {
  to = module.user_management.azurerm_role_assignment.sp_contributor_test
  id = "/subscriptions/3e6ff8b5-2c9b-48bb-b5fb-6b513b3e1dab/providers/Microsoft.Authorization/roleAssignments/3c91c5b1-b119-77c2-ed3b-1843dc03a79f"
}

import {
  to = module.user_management.azurerm_role_assignment.sp_contributor_prod
  id = "/subscriptions/138f27a5-cb36-412c-a9f0-9b1ba69e0d55/providers/Microsoft.Authorization/roleAssignments/b3e1f126-25eb-5643-1fee-44c908ccf09c"
}

import {
  to = module.user_management.azuread_application_registration.px_deploy_sp["d"]
  id = "/applications/ba1aac57-3048-4d82-965b-32537ab7212b"
}

import {
  to = module.user_management.azuread_service_principal.px_deploy_sp["d"]
  id = "/servicePrincipals/f54903d4-2646-4991-8ea6-5473a637c9a9"
}

import {
  to = module.user_management.azuread_application_federated_identity_credential.px_deploy_sp["d/github-main"]
  id = "ba1aac57-3048-4d82-965b-32537ab7212b/federatedIdentityCredential/d500fd3f-d54c-407a-96a3-7dd9cdb1f382"
}

import {
  to = module.user_management.azuread_application_federated_identity_credential.px_deploy_sp["d/github-environment-dev"]
  id = "ba1aac57-3048-4d82-965b-32537ab7212b/federatedIdentityCredential/0134cb33-a760-4e36-b075-66837e46b0e6"
}

import {
  to = module.user_management.azuread_application_federated_identity_credential.px_deploy_sp["d/github-pull-request"]
  id = "ba1aac57-3048-4d82-965b-32537ab7212b/federatedIdentityCredential/ebaee8f7-617e-4d26-9771-593145d9c191"
}

import {
  to = module.user_management.azurerm_role_assignment.px_deploy_sp_state["d"]
  id = "/subscriptions/138f27a5-cb36-412c-a9f0-9b1ba69e0d55/resourceGroups/px-lakehouse-uc-rg/providers/Microsoft.Storage/storageAccounts/pxlakehousetfstatesa/blobServices/default/containers/px-lakehouse-data/providers/Microsoft.Authorization/roleAssignments/b63aa2ca-bfa7-43a5-8d45-e8246e13724a"
}

import {
  to = module.user_management.databricks_service_principal.px_deploy_sp["d"]
  id = "142219473732276"
}

import {
  to = module.user_management.databricks_mws_permission_assignment.px_deploy_sp["d"]
  id = "1721719261752680|142219473732276"
}

import {
  to = module.user_management.databricks_group.px_admins
  id = "154881628026494"
}

import {
  to = module.user_management.databricks_group_member.px_admins_users["bas.hilgers@outlook.com"]
  id = "154881628026494|148159448788227"
}

import {
  to = module.user_management.databricks_group_member.px_admins_deploy_sp["d"]
  id = "154881628026494|142219473732276"
}

import {
  to = module.user_management.databricks_mws_permission_assignment.px_admins["d"]
  id = "1721719261752680|154881628026494"
}
