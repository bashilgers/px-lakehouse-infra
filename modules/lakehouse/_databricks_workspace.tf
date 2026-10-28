# ===================================================================
# Setup Network Configurations for Databricks Workspace
# ===================================================================

locals {
  service_delegation_actions = [
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
  ]
}

# Register privat subset to vnet
resource "azurerm_subnet" "px_subnet_private" {
  name                 = "${var.app_name}-${var.env}-subnet-private"
  resource_group_name  = azurerm_resource_group.px_rg.name
  virtual_network_name = azurerm_virtual_network.px_vnet.name
  address_prefixes     = var.private_subnet_address_prefixes
  service_endpoints    = var.service_endpoints

  delegation {
    name = "databricks-private-subnet-delegation"
    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = local.service_delegation_actions
    }
  }
}

# Register public subset to vnet
resource "azurerm_subnet" "px_subnet_public" {
  name                 = "${var.app_name}-${var.env}-subnet-public"
  resource_group_name  = azurerm_resource_group.px_rg.name
  virtual_network_name = azurerm_virtual_network.px_vnet.name
  address_prefixes     = var.public_subnet_address_prefixes
  service_endpoints    = var.service_endpoints

  delegation {
    name = "databricks-public-subnet-delegation"
    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = local.service_delegation_actions
    }
  }
}

# Associate private subnet to network security group
resource "azurerm_subnet_network_security_group_association" "px_subnet_private_nsg" {
  subnet_id                 = azurerm_subnet.px_subnet_private.id
  network_security_group_id = azurerm_network_security_group.px_nsg.id
}

# Associate public subnet to network security group
resource "azurerm_subnet_network_security_group_association" "px_subnet_public_nsg" {
  subnet_id                 = azurerm_subnet.px_subnet_public.id
  network_security_group_id = azurerm_network_security_group.px_nsg.id
}

# Associate private subnet to route table (optional)
resource "azurerm_subnet_route_table_association" "px_subnet_private_rt" {
  subnet_id      = azurerm_subnet.px_subnet_private.id
  route_table_id = azurerm_route_table.px_route_table.id
}

# Associate public subnet to route table (optional)
resource "azurerm_subnet_route_table_association" "px_subnet_public_rt" {
  subnet_id      = azurerm_subnet.px_subnet_public.id
  route_table_id = azurerm_route_table.px_route_table.id
}

# Associate public subnet to network address translation (nat) gateway
resource "azurerm_subnet_nat_gateway_association" "px_subnet_public_nat_gateway" {
  subnet_id      = azurerm_subnet.px_subnet_public.id
  nat_gateway_id = azurerm_nat_gateway.px_nat_gateway.id
}

# ===================================================================
# Databricks Workspace
# ===================================================================

# Create databricks workspace
resource "azurerm_databricks_workspace" "px_databricks_workspace" {
  name                                  = "${var.app_name}-${var.env}-dbr"
  managed_resource_group_name           = "${var.app_name}-dbr-managed-${var.env}-rg"
  resource_group_name                   = azurerm_resource_group.px_rg.name
  location                              = azurerm_resource_group.px_rg.location
  sku                                   = "premium"
  public_network_access_enabled         = true
  network_security_group_rules_required = "NoAzureDatabricksRules"
  customer_managed_key_enabled          = true
  tags                                  = var.tags

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.px_vnet.id
    private_subnet_name                                  = azurerm_subnet.px_subnet_private.name
    public_subnet_name                                   = azurerm_subnet.px_subnet_public.name
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.px_subnet_private_nsg.id
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.px_subnet_public_nsg.id
    storage_account_name                                 = replace("${var.app_name}-${var.env}-dbfs", "-", "")  # ??? can this be pointed to the onelake?
    storage_account_sku_name                             = "Standard_LRS"  
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.px_subnet_private_nsg,
    azurerm_subnet_network_security_group_association.px_subnet_public_nsg
  ]
}

# Assign workspace to metastore
resource "databricks_metastore_assignment" "px_databricks_workspace_metastore" {
  provider     = databricks.account
  metastore_id = var.unity_catalog_metastore_id
  workspace_id = azurerm_databricks_workspace.px_databricks_workspace.workspace_id
}

# ===================================================================
# Serverless Network Connectivity
# ===================================================================
# Serverless compute does not run in the vnet. It reaches the storage account,
# key vault and sql server through private endpoint rules on this config, which
# live next to each resource. Each rule stays PENDING until it is approved on
# the target resource.

# Create network connectivity config for serverless compute
resource "databricks_mws_network_connectivity_config" "px_ncc" {
  provider = databricks.account
  name     = "${var.app_name}-${var.env}-ncc"
  region   = azurerm_databricks_workspace.px_databricks_workspace.location
}

# Bind network connectivity config to workspace
resource "databricks_mws_ncc_binding" "px_ncc_binding" {
  provider                       = databricks.account
  network_connectivity_config_id = databricks_mws_network_connectivity_config.px_ncc.network_connectivity_config_id
  workspace_id                   = azurerm_databricks_workspace.px_databricks_workspace.workspace_id
}

# ===================================================================
# Back-end Private Link for Databricks Workspace
# ===================================================================
# Clusters reach the control plane through this private endpoint instead of
# the internet, which is what network_security_group_rules_required expects.

# Create private dns zone for databricks
resource "azurerm_private_dns_zone" "px_private_dns_zone_databricks" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.px_rg.name
  tags                = var.tags
}

# Link private dns zone to vnet
resource "azurerm_private_dns_zone_virtual_network_link" "px_private_dns_zone_databricks_vnet_link" {
  name                  = "${var.app_name}-${var.env}-vnet-databricks-link"
  resource_group_name   = azurerm_resource_group.px_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.px_private_dns_zone_databricks.name
  virtual_network_id    = azurerm_virtual_network.px_vnet.id
  tags                  = var.tags
}

# Create back-end private endpoint for databricks workspace
resource "azurerm_private_endpoint" "px_databricks_private_endpoint" {
  name                          = "${var.app_name}-${var.env}-dbr-pe"
  resource_group_name           = azurerm_resource_group.px_rg.name
  location                      = azurerm_resource_group.px_rg.location
  subnet_id                     = azurerm_subnet.px_subnet_private_endpoints.id
  custom_network_interface_name = "${var.app_name}-${var.env}-dbr-pe-nic"
  tags                          = var.tags

  private_service_connection {
    name                           = "${var.app_name}-${var.env}-dbr-psc"
    private_connection_resource_id = azurerm_databricks_workspace.px_databricks_workspace.id
    subresource_names              = ["databricks_ui_api"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.px_private_dns_zone_databricks.id]
  }
}

# ===================================================================
# Front-end Context-based Ingress for Databricks Workspace
# ===================================================================
# Managed at account level, so a wrong ip range can be fixed from anywhere
# through the account api, even when the workspace itself denies you.

# Look up the environment's CI deploy service principle (managed in user_management)
data "databricks_service_principal" "px_deploy_sp" {
  provider     = databricks.account
  display_name = "${var.app_name}-${var.env}-deploy-sp"
}

# Create network policy that only lets listed ip addresses and the deploy
# service principle reach the workspace
resource "databricks_account_network_policy" "px_network_policy" {
  provider          = databricks.account
  account_id        = var.databricks_account_id
  network_policy_id = "${var.app_name}-${var.env}-network-policy"

  ingress = {
    public_access = {
      restriction_mode = "RESTRICTED_ACCESS"
      allow_rules = [
        {
          label = "allowed-ip-addresses"
          destination = {
            all_destinations = true
          }
          origin = {
            included_ip_ranges = {
              ip_ranges = var.workspace_allowed_ip_addresses
            }
          }
        },
        {
          # CI runs on GitHub-hosted runners without stable IPs, so the deploy
          # service principle is allowed by identity, for the api only
          label = "deploy-sp-api"
          authentication = {
            identity_type = "IDENTITY_TYPE_SELECTED_IDENTITIES"
            identities = [
              {
                principal_id   = tonumber(data.databricks_service_principal.px_deploy_sp.id)
                principal_type = "PRINCIPAL_TYPE_SERVICE_PRINCIPAL"
              }
            ]
          }
          destination = {
            workspace_api = {
              scopes = ["all-apis"]
            }
          }
          origin = {
            all_ip_ranges = true
          }
        }
      ]
    }
  }

  # Leave serverless egress unrestricted, this policy only governs ingress
  egress = {
    network_access = {
      restriction_mode = "FULL_ACCESS"
      policy_enforcement = {
        enforcement_mode = "ENFORCED"
      }
    }
  }
}

# Attach network policy to workspace
resource "databricks_workspace_network_option" "px_workspace_network_option" {
  provider          = databricks.account
  workspace_id      = azurerm_databricks_workspace.px_databricks_workspace.workspace_id
  network_policy_id = databricks_account_network_policy.px_network_policy.network_policy_id

  # Clusters must reach the control plane privately before public access is restricted
  depends_on = [azurerm_private_endpoint.px_databricks_private_endpoint]
}
