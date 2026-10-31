locals {
  # Every admin user: of the metastore, and of each environment
  admin_user_names = toset(concat(var.admin_user_names, flatten([for environment in var.environments : environment.admin_user_names])))


  # Each environment's admin users, one entry per environment and user
  env_admin_users = merge([
    for env, environment in var.environments : {
      for user in environment.admin_user_names : "${env}/${user}" => { env = env, user = user }
    }
  ]...)
}

# Look up admin users in databricks account
data "databricks_user" "px_admins" {
  for_each  = local.admin_user_names
  provider  = databricks.account
  user_name = each.key
}

# ===================================================================
# Environment Admin Groups (one per environment)
# ===================================================================
# Owns what px-lakehouse-data creates in the environment. Its members are the
# environment's admin users and its deploy service principle, which is in no
# other environment's group, so CI for one environment can't change another's.

# Create admin group in databricks account per environment
resource "databricks_group" "px_env_admins" {
  for_each     = var.environments
  provider     = databricks.account
  display_name = "${var.app_name}-${each.key}-admins"
}

# Add environment's admin users to its group
resource "databricks_group_member" "px_env_admins_users" {
  for_each  = local.env_admin_users
  provider  = databricks.account
  group_id  = databricks_group.px_env_admins[each.value.env].id
  member_id = data.databricks_user.px_admins[each.value.user].id
}

# Add environment's deploy service principle to its group
resource "databricks_group_member" "px_env_admins_deploy_sp" {
  for_each  = var.environments
  provider  = databricks.account
  group_id  = databricks_group.px_env_admins[each.key].id
  member_id = databricks_service_principal.px_deploy_sp[each.key].id
}

# ===================================================================
# Metastore Admin Group
# ===================================================================
# Owns the metastore, which makes its members metastore admins. Humans only:
# the deploy service principles are in the admin groups above, and CI must not
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
