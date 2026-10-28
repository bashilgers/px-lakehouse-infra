# ===================================================================
# Deploy Service Principles for CI (one per environment)
# ===================================================================
# GitHub Actions logs in as these through federated credentials, so there is
# no secret to store or rotate.

# Create app in app registry per environment
resource "azuread_application_registration" "px_deploy_sp" {
  for_each     = var.environments
  display_name = "${var.app_name}-${each.key}-deploy-sp"
}

# Grab client_id of app and create service principle per environment
resource "azuread_service_principal" "px_deploy_sp" {
  for_each  = var.environments
  client_id = azuread_application_registration.px_deploy_sp[each.key].client_id
}

# Let github actions log in as the deploy service principle
resource "azuread_application_federated_identity_credential" "px_deploy_sp" {
  for_each = merge([
    for env, environment in var.environments : {
      for name, subject in environment.github_subjects : "${env}/${name}" => {
        env        = env
        name       = name
        subject    = subject
        repository = environment.github_repository
      }
    }
  ]...)

  application_id = azuread_application_registration.px_deploy_sp[each.value.env].id
  display_name   = each.value.name
  description    = "GitHub Actions, ${each.value.repository}"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = each.value.subject
  audiences      = ["api://AzureADTokenExchange"]
}

# Let deploy service principle read and write the terraform state
resource "azurerm_role_assignment" "px_deploy_sp_state" {
  for_each             = var.environments
  provider             = azurerm.azurerm_prod
  scope                = var.terraform_state_container_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.px_deploy_sp[each.key].object_id
}

# Register deploy service principle in databricks account
resource "databricks_service_principal" "px_deploy_sp" {
  for_each       = var.environments
  provider       = databricks.account
  application_id = azuread_application_registration.px_deploy_sp[each.key].client_id
  display_name   = "${var.app_name}-${each.key}-deploy-sp"
}

# Give deploy service principle access to its environment's workspace
resource "databricks_mws_permission_assignment" "px_deploy_sp" {
  for_each     = var.environments
  provider     = databricks.account
  workspace_id = each.value.workspace_id
  principal_id = databricks_service_principal.px_deploy_sp[each.key].id
  permissions  = ["USER"]
}
