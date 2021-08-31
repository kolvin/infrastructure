locals {
  region            = "eu-west-1"
  environment       = "dev"
  product_name      = "webserver"
  creator           = "terraform"
  cluster_name      = "${local.environment}-${local.product_name}"

  cdir_prefix       = "11.120"
}