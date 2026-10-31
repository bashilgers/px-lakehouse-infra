# ===================================================================
# Platform Admin Group in Entra ID
# ===================================================================
# The admin users, as one Entra ID group: Azure rights of the platform go to
# it, never to a user. It reads and writes every state (_storage_account.tf)
# and administers the SQL servers (lakehouse). Made here, in the first plan,
# so every later plan can use it. Its members are in the code, unlike the
# persona groups': whoever is in it can change everything.

# Create security group in entra id
resource "azuread_group" "px_platform_admins" {
  display_name            = "${var.app_name}-platform-admins"
  description             = "Admin users of ${var.app_name}: read and write every Terraform state, administer the SQL servers"
  security_enabled        = true
  prevent_duplicate_names = true
  owners                  = var.admin_object_ids
  members                 = var.admin_object_ids
}
