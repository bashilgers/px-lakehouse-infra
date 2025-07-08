# Unity Catalog Metastore

This module contains Terraform code used to create a Unity Catalog metastore on Azure.

## Module Content

This module performs the following tasks:

- Creation of central resource group for Unity Catalog resources
- Creation of central storage account for Unity Catalog metastore
- Creation of Databricks access connector
- Assignment of necessary permissions
- Creation of Unity Catalog metastore resource with created storage account as storage root
