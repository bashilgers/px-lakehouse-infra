#!/usr/bin/env bash
# Destroys one environment's lakehouse plan (plans/<env>), data included. Tear down px-lakehouse-data's objects in
# the environment first: they live in the shared metastore and use its storage credential.
#
# Usage: scripts/teardown-environment.sh <env> [terraform apply/destroy options, e.g. -auto-approve]
#
# The lakehouse module guards the environment against a destroy, and a destroy also trips over two things.
# For this run only, an override file in the module:
# - lifts prevent_destroy on the catalog container and the workspace settings;
# - opens the isolated credentials: a destroy deletes their workspace bindings first, after which an isolated
#   credential is visible to no workspace and can't be deleted;
# - lets the resource group go with what Azure added to it (network intent policies, Event Grid topics).
# The apply opens the credentials; the destroy then removes everything, retried while the account still counts the
# deleted workspace. The override file is always removed again.

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

resource "azurerm_storage_container" "container_catalog" {
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

# The account counts a deleted workspace for 5 to 11 minutes (2026-10-31), and refuses to delete the network
# connectivity config while it does. Destroy again until it lets go.
for attempt in $(seq 1 15); do
  if terraform destroy -input=false "$@"; then
    exit
  fi
  echo "Destroy failed (attempt $attempt); the account may still count the deleted workspace. Retrying in 2 minutes."
  sleep 120
done
exit 1
