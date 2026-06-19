data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid    = "EnableRootAccountAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_number}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowVMImportUseOfKey"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vmie.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowS3UseOfKey"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "s3" {
  description             = "KMS key for ${var.application_name} VM import S3 bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_policy.json

  tags = merge(
    var.tags,
    {
      Name = "${var.application_name}-vm-import-s3-key"
    }
  )
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.application_name}-vm-import-s3"
  target_key_id = aws_kms_key.s3.key_id
}

module "s3-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=76321e50b20f5c0d918cd45bdcf0b62049f5baf1" # v10.1.0

  providers = {
    aws.bucket-replication = aws.bucket-replication
  }
  bucket_prefix       = var.bucket_prefix
  replication_enabled = false
  custom_kms_key      = aws_kms_key.s3.arn

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
      },
      {
         "Effect": "Allow",
         "Action": [
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:GenerateDataKey"
         ],
         "Resource": "${aws_kms_key.s3.arn}"
      }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vmimport_policy_attachment" {
  role       = aws_iam_role.vmimport.name
  policy_arn = aws_iam_policy.vmimport-policy.arn
}
