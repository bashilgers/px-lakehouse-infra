# Data Lakehouse Platform Infrastructure

This repository contains Terraform blueprints to provision a Lakehouse platform as code.

![Azure Lakehouse platform](./images/diagram.png?raw=true)

## Apply order

One apply per plan, in this order. A plan finds what the plans before it made by name, so nothing is copied between
them. `docs/rebuild-guide.html` has the steps, the checks and the steps by hand.

1. `plans/terraform_state`: the storage account that holds every plan's state, its own included, and
   `px-lakehouse-platform-admins`, the admin users' Entra group, which holds their Azure rights. Where the account
   doesn't exist yet, run `plans/terraform_state/bootstrap.sh` once.
2. `plans/user_management`: the Entra groups, app registrations and service principals, the Databricks groups, and
   px-lakehouse-data's GitHub environments and `DEPLOY_CLIENT_IDS` variable. Set `GITHUB_TOKEN` to a token that
   administers that repository, such as `gh auth token`.
3. `plans/unity_catalog_metastore`: the metastore, without storage of its own.
4. `plans/dev`, `plans/test` and `plans/prod`, in parallel if you like (start them a minute apart): each environment,
   its workspace access, its persona groups in the Databricks account and its metastore grant. Approving its private
   endpoints takes the Azure CLI.

Every run needs `ARM_TENANT_ID` set to the tenant. Nothing else is by hand on this side; px-lakehouse-data's step,
`scripts/sql-access.sh`, is the one script outside Terraform, as it handles a secret.

## Tear down

In reverse order, after px-lakehouse-data's objects, with Terraform only:

1. `scripts/teardown-environment.sh <env>` per environment, which lifts the module's guards for that run only.
2. `terraform destroy` in `plans/unity_catalog_metastore`, then in `plans/user_management` (with `GITHUB_TOKEN`).
3. `plans/terraform_state/teardown.sh`, the reverse of `bootstrap.sh`: it moves the state out of the account it
   deletes.
