#!/usr/bin/env bash
# First apply of terraform_state, where the state account doesn't exist yet. Applies on local state, then moves
# that state into the account it just made. Run it once; after that, plan and apply this plan as any other.
#
# Usage: plans/terraform_state/bootstrap.sh (with az login, and ARM_TENANT_ID set)

set -euo pipefail
cd "$(dirname "$0")"

# An override file replaces the backend for this run only, so providers.tf stays as it is
trap 'rm -f backend_override.tf' EXIT
printf 'terraform {\n  backend "local" {}\n}\n' > backend_override.tf
terraform init -input=false -reconfigure
terraform apply -input=false

# The admins' data role on the account can take some minutes to apply
rm -f backend_override.tf
for attempt in 1 2 3 4 5 6; do
  if terraform init -input=false -migrate-state -force-copy; then
    rm -f terraform.tfstate terraform.tfstate.backup
    terraform plan -input=false -detailed-exitcode
    exit
  fi
  echo "Migration failed (attempt $attempt), waiting a minute for the data role"
  sleep 60
done
exit 1
