# ===================================================================
# Azure Data Factory
# ===================================================================
# TODO: add additional (network) configuration and connections

# Create Azure Data Factory
resource "azurerm_data_factory" "px_adf" {
  name                = "${var.app_name}-${var.env}-adf"
  resource_group_name = azurerm_resource_group.px_rg.name
  location            = azurerm_resource_group.px_rg.location
  tags                = var.tags
}
