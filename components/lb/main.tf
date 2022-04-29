resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = var.access_logs

    content {
      bucket       = access_logs.value.bucket
      prefix       = access_logs.value.prefix
      enabled      = access_logs.value.enabled
    }
  }

  tags = var.tags
}