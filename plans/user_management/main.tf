module "user_management" {
  source               = "../../modules/user_management"
  app_name             = "px-lakehouse"
  subscription_id_dev  = "1ab862af-7c5d-4085-ae0b-af6407432de5"
  subscription_id_test = "138f27a5-cb36-412c-a9f0-9b1ba69e0d55"
  subscription_id_prod = "3e6ff8b5-2c9b-48bb-b5fb-6b513b3e1dab"
}
