#!/usr/bin/env bash
# Destroys one environment's lakehouse plan (plans/<env>), data included. Tear down px-lakehouse-data's objects in
# the environment first: they live in the shared metastore and use its storage credential.
#
# Usage: scripts/teardown-environment.sh <env> [terraform apply/destroy options, e.g. -auto-approve]
#
# The lakehouse module guards the environment against a destroy, and a destroy also trips over two things.
# For this run only, an override file in the module:
# - lifts prevent_destroy on the storage account and the workspace settings;
# - opens the isolated credentials: a destroy deletes their workspace bindings first, after which an isolated
#   credential is visible to no workspace and can't be deleted;
# - lets the resource group go with what Azure added to it (network intent policies, Event Grid topics).
# The apply opens the credentials; the destroy then removes everything. The override file is always removed again.

set -euo pipefail
env=$1
shift
root=$(cd "$(dirname "$0")/.." && pwd)
override=$root/modules/lakehouse/teardown_override.tf

trap 'rm -f "$override"' EXIT
cat > "$override" <<'EOF'
# Written by scripts/teardown-environment.sh for one teardown, and removed after it. Never commit.

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_storage_account" "px_storage_account" {
  lifecycle {
    prevent_destroy = false
  }
}

resource "databricks_workspace_conf" "px_workspace_conf" {
  lifecycle {
    prevent_destroy = false
  }
}

resource "databricks_storage_credential" "px_dbr_adls_credential" {
  isolation_mode = "ISOLATION_MODE_OPEN"
}

resource "databricks_credential" "px_sql_credential" {
  isolation_mode = "ISOLATION_MODE_OPEN"
}
EOF

cd "$root/plans/$env"
terraform init -input=false
terraform apply -input=false "$@"
terraform destroy -input=false "$@"
