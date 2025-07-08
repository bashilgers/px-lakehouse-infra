# ===================================================================
# Create Service Principle in App Registry
# ===================================================================

# Create app in app registry
resource "azuread_application_registration" "px_sp" {
  display_name = "${var.app_name}-sp"
  description  = "Master Service Principle for entire Data Platform"
}

# Grab client_id of app and create service principle
resource "azuread_service_principal" "px_sp" {
  client_id                    = azuread_application_registration.px_sp.client_id
  app_role_assignment_required = false
}

# Create password secret for service principle
resource "azuread_service_principal_password" "px_sp" {
  service_principal_id = azuread_service_principal.px_sp.id
}


# ===================================================================
# Add Service Principle as Contributor to all Subscriptions
# ===================================================================

# Add service principle as global AD administrator
resource "azuread_directory_role" "global_admin" {
  display_name = "Global Administrator"
}

resource "azuread_directory_role_assignment" "global_admin" {
  role_id             = azuread_directory_role.global_admin.template_id
  principal_object_id = azuread_service_principal.px_sp.object_id
}

# Add service principle as subscription contributor
resource "azurerm_role_assignment" "sp_contributor_dev" {
  provider             = azurerm.azurerm_dev
  scope                = "/subscriptions/${var.subscription_id_dev}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.px_sp.object_id
}

resource "azurerm_role_assignment" "sp_contributor_test" {
  provider             = azurerm.azurerm_test
  scope                = "/subscriptions/${var.subscription_id_test}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.px_sp.object_id
}

resource "azurerm_role_assignment" "sp_contributor_prod" {
  provider             = azurerm.azurerm_prod
  scope                = "/subscriptions/${var.subscription_id_prod}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.px_sp.object_id
}


# ===================================================================
# Active Directory Group and Member Addition (TODO)
# ===================================================================

# # Create active directory group with service principle as owner
# resource "azuread_group" "px_adgroup" {
#   display_name     = "px_lakehouse_adgroup"
#   owners           = [azuread_service_principal.px_sp.object_id]
#   security_enabled = true
# }

# # Add service principle also as group member
# resource "azuread_group_member" "px_adgroup_sp_member" {
#   member_object_id = azuread_service_principal.px_sp.object_id
#   group_object_id = azuread_group.px_adgroup.id
# }


# ===================================================================
# Create Service Principle in App Registry (TODO)
# ===================================================================

# # Register secret in specific key vault
# resource "azurerm_key_vault_secret" "sp_data_secret" {
#   name         = "${var.app_name}-sp-secret"
#   key_vault_id = var.key_vault_id
# }

# # Register secret in specific key vault
# resource "azurerm_key_vault_secret" "sp_data_client_id" {
#   name         = "${var.app_name}-sp-client-id"
#   key_vault_id = var.key_vault_id
# }
