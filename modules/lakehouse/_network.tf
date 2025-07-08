# ===================================================================
# Network Related Resources
# ===================================================================

# Create virtual network
resource "azurerm_virtual_network" "px_vnet" {
  name                = "${var.app_name}-${var.env}-vnet"
  resource_group_name = azurerm_resource_group.px_rg.name
  location            = azurerm_resource_group.px_rg.location
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

# Create network security group
resource "azurerm_network_security_group" "px_nsg" {
  name                = "${var.app_name}-${var.env}-nsg"
  resource_group_name = azurerm_resource_group.px_rg.name
  location            = azurerm_resource_group.px_rg.location
  tags                = var.tags
}

# Create route table (optional)
resource "azurerm_route_table" "px_route_table" {
  name                = "${var.app_name}-${var.env}-rt"
  resource_group_name = azurerm_resource_group.px_rg.name
  location            = azurerm_resource_group.px_rg.location
  tags                = var.tags
}

# Create network address translation (nat) gateway
resource "azurerm_nat_gateway" "px_nat_gateway" {
  name                = "${var.app_name}-${var.env}-nat"
  resource_group_name = azurerm_resource_group.px_rg.name
  location            = azurerm_resource_group.px_rg.location
  tags                = var.tags
}

# Create public IP resource
resource "azurerm_public_ip" "px_public_ip" {
  name                = "${var.app_name}-${var.env}-public-ip"
  resource_group_name = azurerm_resource_group.px_rg.name
  location            = azurerm_resource_group.px_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Associate public IP to nat gateway
resource "azurerm_nat_gateway_public_ip_association" "px_nat_public_ip" {
  nat_gateway_id       = azurerm_nat_gateway.px_nat_gateway.id
  public_ip_address_id = azurerm_public_ip.px_public_ip.id
}
