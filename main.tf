module "s3-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=8688bc15a08fbf5a4f4eef9b7433c5a417df8df1"

  providers = {
    aws.bucket-replication = aws.bucket-replication
  }
  bucket_prefix       = var.bucket_prefix
  replication_enabled = false

  lifecycle_rule = [
    {
      id      = "main"
      enabled = "Enabled"
      prefix  = ""

      tags = {
        rule      = "log"
        autoclean = "true"
      }

      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 730
      }

      noncurrent_version_transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_expiration = {
        days = 730
      }
    }
  ]

  tags = var.tags
}

resource "aws_iam_role" "vmimport" {
  name               = "vmimport"
  assume_role_policy = data.aws_iam_policy_document.vmimport-trust-policy.json
  tags = merge(
    var.tags,
    {
      Name = "${var.application_name}-vmimport-role"
    }
  )
}

data "aws_iam_policy_document" "vmimport-trust-policy" {
  version = "2012-10-17"
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "vmie.amazonaws.com"
      ]
    }
  }
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "vmimport-policy" {
#checkov:skip=CKV_AWS_289: "Wildcard used as this is a consumable module"
#checkov:skip=CKV_AWS_290: "Wildcard used as this is a consumable module"
#checkov:skip=CKV_AWS_355: "ec2:Describe* achieves same goal as allowing all describe actions"
  name   = "vmimport-policy-${var.application_name}"
  policy = <<EOF
{
  "Version":"2012-10-17",
   "Statement":[
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetBucketAcl"
         ],
         "Resource": [
            "${module.s3-bucket.bucket.arn}",
            "${module.s3-bucket.bucket.arn}/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource": "*"
      }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vmimport_policy_attachment" {
  role       = aws_iam_role.vmimport.name
  policy_arn = aws_iam_policy.vmimport-policy.arn
}
