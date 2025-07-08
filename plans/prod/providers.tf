terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.52.0"
    }
  }
}

provider "databricks" {
  alias = "workspace"
  host  = module.lakehouse.workspace_url
}