# ===================================================================
# Create Service Principal in App Registry (retired)
# ===================================================================
# Was the bootstrap identity, then the run-as identity of the dev jobs; each
# environment now has its own (_run_as_identities.tf). Kept because it owns
# the system table provider in Databricks, which nobody can change. Once
# px-lakehouse-data grants it nothing, it has no rights left. It was Global
# Administrator and Owner of every subscription, while the SQL connection
# logged in with its secret from key vault; it has no Azure roles and no valid
# secret now.

# Create app in app registry
resource "azuread_application_registration" "px_sp" {
  display_name = "${var.app_name}-sp"
  description  = "Retired: owns the Databricks system table provider, no other rights"
}

# Grab client_id of app and create service principal
resource "azuread_service_principal" "px_sp" {
  client_id                    = azuread_application_registration.px_sp.client_id
  app_role_assignment_required = false
}
