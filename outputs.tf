output "role" {
  description = "IAM role name output"
  value       = aws_iam_role.vmimport
}

output "policy" {
  description = "IAM policy name output"
  value       = aws_iam_policy.vmimport-policy
}

output "kms_key" {
  description = "KMS key used to encrypt the VM import S3 bucket"
  value       = aws_kms_key.s3
}

output "kms_alias" {
  description = "KMS alias for the VM import S3 bucket encryption key"
  value       = aws_kms_alias.s3
}
