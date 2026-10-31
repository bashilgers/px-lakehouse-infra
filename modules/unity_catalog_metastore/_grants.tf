# ===================================================================
# Metastore Grants for Environment Admin Groups, moved to the lakehouse module
# ===================================================================
# Each environment's lakehouse plan grants its own admin group, through its
# own workspace, so this plan needs no workspace. Forget the grants here
# without revoking them; each lakehouse plan imports its own.

removed {
  from = databricks_grant.uc_metastore_env_admins
  lifecycle {
    destroy = false
  }
}
