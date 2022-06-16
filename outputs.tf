output "role" {
  description = "IAM role name output"
  value       = aws_iam_role.vmimport
}

output "policy" {
  description = "IAM policy name output"
  value       = aws_iam_policy.vmimport-policy
}
