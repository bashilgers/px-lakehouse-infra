# Adopts what user_management and unity_catalog_metastore managed before this
# plan took it over: the workspace assignments and the metastore grant. Remove
# this file once applied.

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_env_admins
  id = "7405604947705518|155472053182943"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_deploy_sp
  id = "7405604947705518|147062187119541"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_run_sp
  id = "7405604947705518|143002013519656"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_persona["engineers"]
  id = "7405604947705518|150402541173627"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_persona["readers"]
  id = "7405604947705518|153035770299061"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_persona["support"]
  id = "7405604947705518|150086705072689"
}

import {
  to = module.lakehouse.databricks_grant.px_metastore_env_admins
  id = "metastore/c4ffc048-f9f8-4401-a393-238a3c29fae0/px-lakehouse-p-admins"
}
