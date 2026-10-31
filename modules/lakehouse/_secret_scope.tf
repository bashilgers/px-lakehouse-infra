# ===================================================================
# Secret Scope
# ===================================================================
# The key vault in Databricks, for the connections' and jobs' secrets.
# Creating a key vault-backed scope takes an Entra ID login that may change
# the key vault (Key Vault Contributor, Contributor or Owner): Databricks
# writes to it as the scope's creator. px-lakehouse-data's deploy service
# principle has no role on the key vault, so the scope is here. Every ACL is
# listed. Workspace admins manage every scope anyway, without an ACL.

# Look up whoever applies this plan, the scope's creator. Read once the
# workspace exists.
data "databricks_current_user" "px_me" {
  provider   = databricks.workspace
  depends_on = [azurerm_databricks_workspace.px_databricks_workspace]
}

# Create key vault-backed secret scope
resource "databricks_secret_scope" "px_secret_scope" {
  provider = databricks.workspace
  name     = "${var.app_name}-keyvault"

  keyvault_metadata {
    resource_id = azurerm_key_vault.px_key_vault.id
    dns_name    = azurerm_key_vault.px_key_vault.vault_uri
  }

  # Databricks reads the secrets as the AzureDatabricks application
  depends_on = [azurerm_role_assignment.px_key_vault_databricks_secrets_user]
}

# Let the metastore admins manage the scope: a group of the admin users, not
# the environment's admin group, which holds its deploy service principle
resource "databricks_secret_acl" "px_secret_scope_managers" {
  provider   = databricks.workspace
  scope      = databricks_secret_scope.px_secret_scope.name
  principal  = var.metastore_admins_group_name
  permission = "MANAGE"

  # A principal gets an ACL only once it is in the workspace
  depends_on = [databricks_mws_permission_assignment.px_metastore_admins]
}

# Take away the MANAGE that Databricks gives the scope's creator: only groups
# hold ACLs. The creator, an admin user, keeps it through the group above.
# Terraform has no resource for an ACL that must not exist, so this deletes it
# once, after the scope is made; it is gone already when the scope is older
# than this.
resource "terraform_data" "px_secret_scope_creator_removal" {
  triggers_replace = [databricks_secret_scope.px_secret_scope.id]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    environment = {
      DATABRICKS_HOST      = "https://${azurerm_databricks_workspace.px_databricks_workspace.workspace_url}"
      DATABRICKS_AUTH_TYPE = "azure-cli"
      SCOPE                = databricks_secret_scope.px_secret_scope.name
      CREATOR              = data.databricks_current_user.px_me.user_name
    }
    command = <<-EOT
      set -euo pipefail
      if databricks secrets get-acl "$SCOPE" "$CREATOR" >/dev/null 2>&1; then
        databricks secrets delete-acl "$SCOPE" "$CREATOR"
      fi
      echo "$SCOPE: no ACL for $CREATOR"
    EOT
  }

  depends_on = [databricks_secret_acl.px_secret_scope_managers]
}

# Forget the creator's ACL that this plan used to list, without deleting it
# here: the removal above deletes it, after the group's MANAGE is in
removed {
  from = databricks_secret_acl.px_secret_scope_creator

  lifecycle {
    destroy = false
  }
}

# Let the run-as service principle and the other secret readers read the
# secrets. Nobody else gets an ACL: whoever can read the scope has the SQL
# service principle's secret, and whoever manages it can read it.
resource "databricks_secret_acl" "px_secret_scope_readers" {
  for_each   = toset(concat([data.databricks_service_principal.px_run_sp.application_id], var.secret_readers))
  provider   = databricks.workspace
  scope      = databricks_secret_scope.px_secret_scope.name
  principal  = each.key
  permission = "READ"

  # A principal gets an ACL only once it is in the workspace
  depends_on = [
    databricks_mws_permission_assignment.px_run_sp,
    databricks_mws_permission_assignment.px_persona,
  ]
}
