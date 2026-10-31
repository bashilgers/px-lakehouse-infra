# Adopts what user_management and unity_catalog_metastore managed before this
# plan took it over: the workspace assignments and the metastore grant. Remove
# this file once applied.

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_env_admins
  id = "7405619574554186|151069734128868"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_deploy_sp
  id = "7405619574554186|144324008753511"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_run_sp
  id = "7405619574554186|144953427631184"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_persona["engineers"]
  id = "7405619574554186|153604294445444"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_persona["readers"]
  id = "7405619574554186|157730243043207"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_persona["support"]
  id = "7405619574554186|154177058539362"
}

import {
  to = module.lakehouse.databricks_grant.px_metastore_env_admins
  id = "metastore/c4ffc048-f9f8-4401-a393-238a3c29fae0/px-lakehouse-d-admins"
}
