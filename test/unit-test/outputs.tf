output "role_name" {
  value       = module.vm-import.role.name
  description = "IAM role name output"
}

output "policy_name" {
  value       = module.vm-import.policy.name
  description = "IAM policy name output"
}
