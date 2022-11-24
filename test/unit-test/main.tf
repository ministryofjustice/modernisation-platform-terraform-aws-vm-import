module "vm-import" {

  source = "github.com/ministryofjustice/modernisation-platform-terraform-aws-vm-import?ref=v1.0.2"

  bucket_prefix    = local.application_data.accounts["test"].bucket_prefix
  tags             = local.tags
  application_name = local.application_name
  account_number   = local.environment_management.account_ids["testing-test"]

}
