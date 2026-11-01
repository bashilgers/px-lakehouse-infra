# ===================================================================
# GitHub Environments and Deploy Identities (one per environment)
# ===================================================================
# What px-lakehouse-data's workflow needs from GitHub: per environment a
# GitHub environment that only main can deploy from, which its deploy service
# principal's federated credential trusts (_deploy_identities.tf), and the
# deploy service principals' client IDs, which change with every rebuild, as
# a repository variable the workflow reads.

# Create github environment per environment, deployable from main only
resource "github_repository_environment" "px_deploy" {
  for_each    = var.environments
  repository  = split("/", each.value.github_repository)[1]
  environment = each.value.github_environment

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

# Let only main deploy to the github environment
resource "github_repository_environment_deployment_policy" "px_deploy_main" {
  for_each       = var.environments
  repository     = github_repository_environment.px_deploy[each.key].repository
  environment    = github_repository_environment.px_deploy[each.key].environment
  branch_pattern = "main"
}

# Publish each deploy service principal's client id to its repository, by
# github environment name: {"dev": "<client id>", ...}
resource "github_actions_variable" "px_deploy_client_ids" {
  for_each      = toset([for environment in var.environments : environment.github_repository])
  repository    = split("/", each.key)[1]
  variable_name = "DEPLOY_CLIENT_IDS"
  value = jsonencode({
    for env, environment in var.environments : environment.github_environment => azuread_application_registration.px_deploy_sp[env].client_id
    if environment.github_repository == each.key
  })
}
