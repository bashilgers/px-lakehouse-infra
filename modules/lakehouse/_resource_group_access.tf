# ===================================================================
# Resource Group Access
# ===================================================================
# Azure rights on the environment's resource group go to groups. The platform
# admins own it, so the platform doesn't depend on who owns the subscription.
# Where the environment has engineers, they see its resources in the portal:
# Reader gives no data, as data access goes through Unity Catalog.

resource "azurerm_role_assignment" "px_rg_platform_admins" {
  scope                = azurerm_resource_group.px_rg.id
  role_definition_name = "Owner"
  principal_id         = data.azuread_group.px_platform_admins.object_id
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "px_rg_engineers" {
  for_each             = contains(var.personas, "engineers") ? toset(["engineers"]) : toset([])
  scope                = azurerm_resource_group.px_rg.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.px_persona[each.key].object_id
  principal_type       = "Group"
}
