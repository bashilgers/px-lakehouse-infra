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
