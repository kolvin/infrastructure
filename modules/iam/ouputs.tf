output "terragrunt-role" {
  value       = aws_iam_role.terragrunt
  description = "Role for terragrunt to assume"
}