module "terraform_state" {
  source          = "../../modules/terraform_state"
  subscription_id = "138f27a5-cb36-412c-a9f0-9b1ba69e0d55"
  app_name        = "px-lakehouse"
  location        = "westeurope"
  containers = [
    "px-lakehouse-infra",  # every plan of this repository, written by the admins
    "px-lakehouse-d-data", # px-lakehouse-data dev, written by its deploy identity
    "px-lakehouse-t-data", # px-lakehouse-data test
    "px-lakehouse-p-data", # px-lakehouse-data prod
    # Retired: px-lakehouse-data's states before the names above. Empty once it has moved;
    # taking them out needs prevent_destroy lifted for that apply.
    "px-lakehouse-data",
    "px-lakehouse-data-t",
    "px-lakehouse-data-p",
  ]
  # The platform admin group's members, by Entra ID object ID: bas.hilgers@outlook.com
  admin_object_ids = ["c0071a22-3f84-4337-ad09-871f52c3a1ba"]
  tags = {
    app                 = "px-lakehouse"
    app-sme             = "bas.hilgers@outlook.com"
    app-owner           = "bas.hilgers@outlook.com"
    data-classification = "confidential"
    criticality         = "1-critical"
    environment         = "prod"
  }
}

# For terraform_state_container_id in user_management
output "container_ids" {
  value = module.terraform_state.container_ids
}
