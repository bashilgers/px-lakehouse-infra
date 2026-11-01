#!/usr/bin/env bash
# Last step of a full teardown, the reverse of bootstrap.sh: destroys this plan, the state account with every state in
# it and the platform admin group. Run it after every other plan of both repositories is destroyed. The destroy
# deletes the account that holds this plan's own state, so the state moves to a local file first. For this run only,
# an override file lifts prevent_destroy on the account and its containers. If the destroy fails, the local state
# stays here and running the script again goes on from it.
#
# Usage: plans/terraform_state/teardown.sh [-auto-approve] (with az login, and ARM_TENANT_ID set)

set -euo pipefail
cd "$(dirname "$0")"
override=../../modules/terraform_state/teardown_override.tf

trap 'rm -f backend_override.tf "$override"' EXIT
if [ ! -f terraform.tfstate ]; then
  terraform init -input=false -reconfigure
fi
printf 'terraform {\n  backend "local" {}\n}\n' > backend_override.tf
if [ ! -f terraform.tfstate ]; then
  terraform init -input=false -migrate-state -force-copy
else
  terraform init -input=false -reconfigure
fi

cat > "$override" <<'EOF'
# Written by plans/terraform_state/teardown.sh for one teardown, and removed after it. Never commit.

resource "azurerm_storage_account" "tfstate" {
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_storage_container" "tfstate" {
  lifecycle {
    prevent_destroy = false
  }
}
EOF

terraform destroy -input=false "$@"
if [ -n "$(terraform state list)" ]; then
  echo "Still in the state: $(terraform state list | tr '\n' ' ')" >&2
  exit 1
fi
rm -f terraform.tfstate terraform.tfstate.backup
echo "Torn down: the state account and the platform admin group"
