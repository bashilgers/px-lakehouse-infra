# ===================================================================
# SQL Service Principals for Lakehouse Federation (one per environment)
# ===================================================================
# The Databricks connection to the environment's SQL database logs in as this
# one, with a client secret from the key vault behind the workspace's secret
# scope. Whoever can read that scope can act as it, so it only reads the
# database (db_datareader): no Azure roles, not in Databricks. Its secret and
# its database user are made by hand, so the secret never lands in the state.

# Create app in app registry per environment
resource "azuread_application_registration" "px_sql_sp" {
  for_each     = var.environments
  display_name = "${var.app_name}-${each.key}-sql-sp"
  description  = "Lakehouse Federation login to the ${each.key} SQL database, read-only"
}

# Grab client_id of app and create service principal per environment
resource "azuread_service_principal" "px_sql_sp" {
  for_each  = var.environments
  client_id = azuread_application_registration.px_sql_sp[each.key].client_id
}
