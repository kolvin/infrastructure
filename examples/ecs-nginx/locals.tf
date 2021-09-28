locals {
  region            = "eu-west-1"
  environment       = "dev"
  product_name      = "symfony"
  creator           = "kolv.in"
  cluster_name      = "${local.environment}-${local.product_name}"

  cdir_prefix       = "11.120"
}