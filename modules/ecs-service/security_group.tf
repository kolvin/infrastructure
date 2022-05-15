resource "aws_security_group" "this" {
  count = (var.associate_default_security_group == "yes" && var.service_task_network_mode == "awsvpc") ? 1 : 0

  name        = "${var.environment}-${var.service_name}"
  description = "Container access for: ${var.environment}, ${var.service_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name                 = "${var.environment}-${var.service_name}"
    Environment          = var.environment
    ServiceName          = var.service_name
  }
}

resource "aws_security_group_rule" "cluster_default_ingress" {
  count = (var.associate_default_security_group == "yes" && var.include_default_ingress_rule == "yes" && var.service_task_network_mode == "awsvpc") ? 1 : 0

  type = "ingress"

  security_group_id = aws_security_group.this.0.id

  protocol  = "-1"
  from_port = 0
  to_port   = 0

  cidr_blocks = var.default_security_group_ingress_cidrs
}

resource "aws_security_group_rule" "cluster_default_egress" {
  count = (var.associate_default_security_group == "yes" && var.include_default_egress_rule == "yes" && var.service_task_network_mode == "awsvpc") ? 1 : 0

  type = "egress"

  security_group_id = aws_security_group.this.0.id

  protocol  = "-1"
  from_port = 0
  to_port   = 0

  cidr_blocks = var.default_security_group_egress_cidrs
}
