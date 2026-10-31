# Data Lakehouse Platform Infrastructure

This repository contains Terraform blueprints to provision a Lakehouse platform as code.

![Azure Lakehouse platform](./images/diagram.png?raw=true)

## Apply order

One apply per plan, in this order. A plan finds what the plans before it made by name, so nothing is copied between
them. `docs/rebuild-guide.html` has the steps, the checks and the steps by hand.

1. `plans/terraform_state`: the storage account that holds every plan's state, its own included. Where it doesn't exist
   yet, run `plans/terraform_state/bootstrap.sh` once.
2. `plans/user_management`: the Entra groups, app registrations and service principals, and the Databricks groups.
3. `plans/unity_catalog_metastore`: the metastore, its storage and its root credential.
4. `plans/dev`, `plans/test` and `plans/prod`, in parallel if you like: each environment, its workspace access and its
   metastore grant. Approving its private endpoints takes the Azure CLI.

## Tear down

In reverse order, after px-lakehouse-data's objects. One command per environment, which lifts the module's guards for
that run only: `scripts/teardown-environment.sh <env>`.
