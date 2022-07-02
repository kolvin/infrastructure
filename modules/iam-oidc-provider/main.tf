resource "aws_iam_openid_connect_provider" "this" {
  url             = var.provider_config.url
  thumbprint_list = var.provider_config.thumbprint_list
  client_id_list  = var.provider_config.client_id_list
}
