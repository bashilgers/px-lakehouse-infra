# ===================================================================
# Admin Group
# ===================================================================
# Owns what Terraform creates in Unity Catalog, so both the admin users and the
# deploy service principles can manage it.

# Create admin group in databricks account
resource "databricks_group" "px_admins" {
  provider     = databricks.account
  display_name = "${var.app_name}-admins"
}

# Look up admin users in databricks account
data "databricks_user" "px_admins" {
  for_each  = toset(var.admin_user_names)
  provider  = databricks.account
  user_name = each.key
}

# Add admin users to group
resource "databricks_group_member" "px_admins_users" {
  for_each  = toset(var.admin_user_names)
  provider  = databricks.account
  group_id  = databricks_group.px_admins.id
  member_id = data.databricks_user.px_admins[each.key].id
}

# Add deploy service principles to group
resource "databricks_group_member" "px_admins_deploy_sp" {
  for_each  = var.environments
  provider  = databricks.account
  group_id  = databricks_group.px_admins.id
  member_id = databricks_service_principal.px_deploy_sp[each.key].id
}

# Give admin group access to each environment's workspace
resource "databricks_mws_permission_assignment" "px_admins" {
  for_each     = var.environments
  provider     = databricks.account
  workspace_id = each.value.workspace_id
  principal_id = databricks_group.px_admins.id
  permissions  = ["USER"]
}

# ===================================================================
# Metastore Admin Group
# ===================================================================
# Owns the metastore, which makes its members metastore admins. Humans only:
# the deploy service principles are in the admin group above, and CI must not
# become metastore admin.

# Create metastore admin group in databricks account
resource "databricks_group" "px_metastore_admins" {
  provider     = databricks.account
  display_name = "${var.app_name}-metastore-admins"
}

# Add admin users to metastore admin group
resource "databricks_group_member" "px_metastore_admins_users" {
  for_each  = toset(var.admin_user_names)
  provider  = databricks.account
  group_id  = databricks_group.px_metastore_admins.id
  member_id = data.databricks_user.px_admins[each.key].id
}
