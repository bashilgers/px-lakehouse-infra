# ===================================================================
# Create Service Principle in App Registry (retired)
# ===================================================================
# Was the bootstrap identity, then the run-as identity of the dev jobs; each
# environment now has its own (_run_as_identities.tf). Kept because it owns
# the system table provider in Databricks, which nobody can change. Once
# px-lakehouse-data grants it nothing, it has no rights left.

# Create app in app registry
resource "azuread_application_registration" "px_sp" {
  display_name = "${var.app_name}-sp"
  description  = "Retired: owns the Databricks system table provider, no other rights"
}

# Grab client_id of app and create service principle
resource "azuread_service_principal" "px_sp" {
  client_id                    = azuread_application_registration.px_sp.client_id
  app_role_assignment_required = false
}


# ===================================================================
# No Directory or Subscription Roles
# ===================================================================
# It was Global Administrator and Owner of every subscription, while the SQL
# connection logged in with its secret from key vault; it has no Azure roles
# and no valid secret now.

# An activated directory role can't be deactivated, so the Global
# Administrator role is only dropped from the state
removed {
  from = azuread_directory_role.global_admin

  lifecycle {
    destroy = false
  }
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
