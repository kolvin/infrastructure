output "role" {
  value       = aws_iam_role.this
  description = "Role for terragrunt to assume"
}