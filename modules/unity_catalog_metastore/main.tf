terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.140.0"
    }
  }
}

provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}
