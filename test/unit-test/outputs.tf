output "role_name" {
  value       = module.vm-import.role.name
  description = "IAM role name output"
}

output "policy_name" {
  value       = module.vm-import.policy.name
  description = "IAM policy name output"
}

output "kms_key_arn" {
  value       = module.vm-import.kms_key.arn
  description = "KMS key ARN used to encrypt the VM import S3 bucket"
}

output "kms_alias_name" {
  value       = module.vm-import.kms_alias.name
  description = "KMS alias name for the VM import S3 bucket encryption key"
}
