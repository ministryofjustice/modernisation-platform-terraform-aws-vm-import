output "role_name" {
  value       = module.vm-import.role
  description = "IAM role name output"
}

output "policy_name" {
  value       = module.vm-import.policy
  description = "IAM policy name output"
}
