output "openid_connect_provider" {
  description = "OpenID Connect Identity Provider"
  value       = aws_iam_openid_connect_provider.this
}
