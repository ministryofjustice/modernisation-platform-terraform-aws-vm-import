## Usage

```hcl

module "vm-import" {

  source = "github.com/ministryofjustice/modernisation-platform-terraform-aws-vm-import"

  bucket_prefix    = local.application_data.accounts[local.environment].bucket_prefix
  tags             = local.tags
  application_name = local.application_name

}

```
<!--- BEGIN_TF_DOCS --->

<!--- END_TF_DOCS --->

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
