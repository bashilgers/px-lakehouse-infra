# Data Lakehouse Platform Infrastructure

This repository contains Terraform blueprints to provision a Lakehouse platform as code.

![Azure Lakehouse platform](./images/diagram.png?raw=true)

## Apply order

`plans/terraform_state` first: it creates the storage account that holds every plan's state, its own included
(bootstrap in its `providers.tf`). Then `user_management`, `unity_catalog_metastore`, and `dev`, `test` and `prod`.
