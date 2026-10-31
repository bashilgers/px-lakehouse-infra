# ===================================================================
# Azure SQL Server and Database
# ===================================================================
# The SQL server lives in var.sql_location, because westeurope refuses new SQL
# servers on these subscriptions. The private endpoint below brings it into the
# vnet, so Databricks reaches it with public network access disabled.

# Create sql server with entra-only authentication
resource "azurerm_mssql_server" "px_sql_server" {
  name                          = "${var.app_name}-${var.env}-sqlsrv"
  resource_group_name           = azurerm_resource_group.px_rg.name
  location                      = var.sql_location
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = var.tags

  azuread_administrator {
    login_username              = var.sql_entra_admin_login
    object_id                   = var.sql_entra_admin_object_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    azuread_authentication_only = true
  }
}

# Create serverless sql database
resource "azurerm_mssql_database" "px_sql_database" {
  name                        = "${var.app_name}-${var.env}-sqldb"
  server_id                   = azurerm_mssql_server.px_sql_server.id
  sku_name                    = "GP_S_Gen5_1"
  max_size_gb                 = 10
  min_capacity                = 0.5
  auto_pause_delay_in_minutes = 60
  storage_account_type        = "Local"
  tags                        = var.tags
}

# ===================================================================
# Private Endpoint for Azure SQL Server
# ===================================================================

# Create private dns zone for sql servers
resource "azurerm_private_dns_zone" "px_private_dns_zone_sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.px_rg.name
  tags                = var.tags
}

# Link private dns zone to vnet
resource "azurerm_private_dns_zone_virtual_network_link" "px_private_dns_zone_sql_vnet_link" {
  name                  = "${var.app_name}-${var.env}-vnet-sql-link"
  resource_group_name   = azurerm_resource_group.px_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.px_private_dns_zone_sql.name
  virtual_network_id    = azurerm_virtual_network.px_vnet.id
  tags                  = var.tags
}

# Create private endpoint for sql server (in the vnet's location, not the server's)
resource "azurerm_private_endpoint" "px_sql_private_endpoint" {
  name                          = "${var.app_name}-${var.env}-sqlsrv-pe"
  resource_group_name           = azurerm_resource_group.px_rg.name
  location                      = azurerm_virtual_network.px_vnet.location
  subnet_id                     = azurerm_subnet.px_subnet_private_endpoints.id
  custom_network_interface_name = "${var.app_name}-${var.env}-sqlsrv-pe-nic"
  tags                          = var.tags

  private_service_connection {
    name                           = "${var.app_name}-${var.env}-sqlsrv-psc"
    private_connection_resource_id = azurerm_mssql_server.px_sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.px_private_dns_zone_sql.id]
  }
}

# Create private endpoint rule from serverless compute to sql server
resource "databricks_mws_ncc_private_endpoint_rule" "px_ncc_sql_private_endpoint_rule" {
  provider                       = databricks.account
  network_connectivity_config_id = databricks_mws_network_connectivity_config.px_ncc.network_connectivity_config_id
  resource_id                    = azurerm_mssql_server.px_sql_server.id
  group_id                       = "sqlServer"
}

# ===================================================================
# Writing to the SQL Database
# ===================================================================
# Jobs write to the database as the managed identity of an access connector of
# its own, through a Unity Catalog service credential, so without a secret. Not
# the storage access connector: ACCESS on a service credential gives tokens for
# any Azure resource its identity can reach, storage included. The identity's
# user in the database, and its roles, are made by hand by the server's Entra
# admin, as public network access is off.

# Create access connector for the writes to the sql database
resource "azurerm_databricks_access_connector" "px_sql_connector" {
  name                = "${var.app_name}-${var.env}-dbr-sqlsrv-connector"
  resource_group_name = azurerm_resource_group.px_rg.name
  location            = azurerm_resource_group.px_rg.location
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

# Create service credential on access connector, owned by the metastore admins
# since whoever owns it can act as its identity. A service principal can only
# create one as account admin, so it is here and not in px-lakehouse-data.
resource "databricks_credential" "px_sql_credential" {
  provider       = databricks.workspace
  name           = azurerm_databricks_access_connector.px_sql_connector.name
  purpose        = "SERVICE"
  owner          = var.metastore_admins_group_name
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  comment        = "Writes to ${azurerm_mssql_database.px_sql_database.name}"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.px_sql_connector.id
  }

  # Made through the workspace, so only once it has the metastore, and deleted
  # before it loses it: a delete after that finds nothing and passes silently
  depends_on = [databricks_metastore_assignment.px_databricks_workspace_metastore]
}

# Bind service credential to the environment's workspace only
resource "databricks_workspace_binding" "px_sql_credential" {
  provider       = databricks.workspace
  securable_type = "credential"
  securable_name = databricks_credential.px_sql_credential.name
  workspace_id   = azurerm_databricks_workspace.px_databricks_workspace.workspace_id
  binding_type   = "BINDING_TYPE_READ_WRITE"
}

# Let the run-as service principle and the other sql writers act as the access
# connector's identity
resource "databricks_grant" "px_sql_credential_writers" {
  for_each   = toset(concat([data.databricks_service_principal.px_run_sp.application_id], var.sql_writers))
  provider   = databricks.workspace
  credential = databricks_credential.px_sql_credential.id
  principal  = each.key
  privileges = ["ACCESS"]
}
