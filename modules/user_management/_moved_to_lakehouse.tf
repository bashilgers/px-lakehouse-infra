# ===================================================================
# Workspace Assignments, moved to the lakehouse module
# ===================================================================
# Each environment's lakehouse plan assigns its identities to its workspace,
# which it creates itself, so this plan no longer needs a workspace ID and runs
# in one pass. Forget the assignments here without removing them; each
# lakehouse plan imports its own.

removed {
  from = databricks_mws_permission_assignment.px_env_admins
  lifecycle {
    destroy = false
  }
}

removed {
  from = databricks_mws_permission_assignment.px_deploy_sp
  lifecycle {
    destroy = false
  }
}

removed {
  from = databricks_mws_permission_assignment.px_run_sp
  lifecycle {
    destroy = false
  }
}

removed {
  from = databricks_mws_permission_assignment.px_persona
  lifecycle {
    destroy = false
  }
}
