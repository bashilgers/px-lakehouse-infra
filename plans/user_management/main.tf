module "user_management" {
  source                = "../../modules/user_management"
  app_name              = "px-lakehouse"
  subscription_id_dev   = "1ab862af-7c5d-4085-ae0b-af6407432de5"
  subscription_id_test  = "3e6ff8b5-2c9b-48bb-b5fb-6b513b3e1dab"
  subscription_id_prod  = "138f27a5-cb36-412c-a9f0-9b1ba69e0d55"
  databricks_account_id = "29c54faf-2e22-47d0-b2bb-f894c93010d2"
  admin_user_names      = ["bas.hilgers@outlook.com"]
  # Entra ID object IDs: bas.hilgers@outlook.com
  group_owner_object_ids = ["c0071a22-3f84-4337-ad09-871f52c3a1ba"]
  environments = {
    d = {
      admin_user_names             = ["bas.hilgers@outlook.com"]
      terraform_state_container_id = "/subscriptions/138f27a5-cb36-412c-a9f0-9b1ba69e0d55/resourceGroups/px-lakehouse-tfstate-rg/providers/Microsoft.Storage/storageAccounts/pxlakehousetfstatesa/blobServices/default/containers/px-lakehouse-data"
      github_repository            = "bashilgers/px-lakehouse-data"
      # GitHub's immutable subject format: owner@owner-id/repo@repo-id. Only dev
      # trusts pull requests (_deploy_identities.tf)
      github_subjects = {
        github-main            = "repo:bashilgers@34332095/px-lakehouse-data@1437225708:ref:refs/heads/main"
        github-environment-dev = "repo:bashilgers@34332095/px-lakehouse-data@1437225708:environment:dev"
        github-pull-request    = "repo:bashilgers@34332095/px-lakehouse-data@1437225708:pull_request"
      }
    }
    t = {
      admin_user_names = ["bas.hilgers@outlook.com"]
      # A container of its own: dev's holds only dev's state
      terraform_state_container_id = "/subscriptions/138f27a5-cb36-412c-a9f0-9b1ba69e0d55/resourceGroups/px-lakehouse-tfstate-rg/providers/Microsoft.Storage/storageAccounts/pxlakehousetfstatesa/blobServices/default/containers/px-lakehouse-data-t"
      github_repository            = "bashilgers/px-lakehouse-data"
      github_subjects = {
        github-main             = "repo:bashilgers@34332095/px-lakehouse-data@1437225708:ref:refs/heads/main"
        github-environment-test = "repo:bashilgers@34332095/px-lakehouse-data@1437225708:environment:test"
      }
    }
    p = {
      admin_user_names = ["bas.hilgers@outlook.com"]
      # A container of its own: dev's holds only dev's state
      terraform_state_container_id = "/subscriptions/138f27a5-cb36-412c-a9f0-9b1ba69e0d55/resourceGroups/px-lakehouse-tfstate-rg/providers/Microsoft.Storage/storageAccounts/pxlakehousetfstatesa/blobServices/default/containers/px-lakehouse-data-p"
      github_repository            = "bashilgers/px-lakehouse-data"
      github_subjects = {
        github-main             = "repo:bashilgers@34332095/px-lakehouse-data@1437225708:ref:refs/heads/main"
        github-environment-prod = "repo:bashilgers@34332095/px-lakehouse-data@1437225708:environment:prod"
      }
    }
  }
}
