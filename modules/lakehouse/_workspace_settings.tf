# ===================================================================
# Workspace Settings
# ===================================================================
# The workspace's admin settings, by their workspace-conf keys (read one with
# `databricks workspace-conf get-status <key>`). Setting them takes a workspace
# admin, which the deploy service principle is not, so they are here and not in
# px-lakehouse-data. Keys not listed keep their value. Taking a key out does not
# leave it as it is: the provider resets it, a true/false key to false and any
# other to empty, and destroying the resource resets them all.

# Set workspace's personal access token, Git URL allow list and visibility settings
resource "databricks_workspace_conf" "px_workspace_conf" {
  provider = databricks.workspace

  custom_config = {
    # Personal access tokens off: CI, Terraform and the CLI log in through
    # Entra ID, and no token was ever made. Nobody can create or use one, admins
    # included, so there are no token permissions to set. Partner Connect and
    # partner integrations need them on; if they are, new ones last 90 days at most.
    enableTokensConfig   = "false"
    maxTokenLifetimeDays = "90"

    # Git folders clone, pull, commit and push only repositories of the GitHub
    # account that holds px-lakehouse's (case-insensitive prefix match)
    enableProjectsAllowList      = "true"
    projectsAllowListPermissions = "ALLOWLISTED_CLONE_COMMIT_PUSH"
    projectsAllowList            = "https://github.com/bashilgers/"

    # Users see only the notebooks, folders, clusters and jobs they have a
    # permission on (Databricks' default, listed so a change by hand shows in a plan)
    enforceWorkspaceViewAcls = "true"
    enforceClusterViewAcls   = "true"
    enableJobViewAcls        = "true"
  }

  # Destroying it turns the allow list and the visibility controls off
  lifecycle {
    prevent_destroy = true
  }
}
