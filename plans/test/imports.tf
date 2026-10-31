# Adopts what user_management and unity_catalog_metastore managed before this
# plan took it over: the workspace assignments and the metastore grant. Remove
# this file once applied.

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_env_admins
  id = "7405605769926036|154343607362211"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_deploy_sp
  id = "7405605769926036|141730357433725"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_run_sp
  id = "7405605769926036|146576869743587"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_persona["engineers"]
  id = "7405605769926036|152065942812834"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_persona["readers"]
  id = "7405605769926036|155416936834115"
}

import {
  to = module.lakehouse.databricks_mws_permission_assignment.px_persona["support"]
  id = "7405605769926036|150781128019685"
}

import {
  to = module.lakehouse.databricks_grant.px_metastore_env_admins
  id = "metastore/c4ffc048-f9f8-4401-a393-238a3c29fae0/px-lakehouse-t-admins"
}
