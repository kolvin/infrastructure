provider "aws" {
  profile = "personal"
  region  = "eu-west-1"
}

module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"
  name   = "${local.environment}-${local.product_name}-vpc"
  cidr = "${local.cdir_prefix}.0.0/16"
  azs             = ["eu-west-1a", "eu-west-1c"]
  private_subnets = ["${local.cdir_prefix}.1.0/24", "${local.cdir_prefix}.3.0/24"]
  public_subnets  = ["${local.cdir_prefix}.101.0/24", "${local.cdir_prefix}.103.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Creator      = local.creator
    Environment  = local.environment
    Product      = local.product_name
  }
}

resource "aws_security_group" "load_balancer_access" {
  name        = "${local.environment}-${local.product_name}-lb-access"
  description = "Access to the ${local.environment} public facing load balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "${local.environment}-${local.product_name}-lb-access"
    Creator      = local.creator
    Environment  = local.environment
    Product      = local.product_name
  }

  vpc_id = module.vpc.vpc_id

  depends_on = [module.vpc]
}

module lb {
  source = "../../modules/lb"

  name = "${local.environment}-${local.product_name}-lb"
  subnets = module.vpc.public_subnets

  security_groups = [aws_security_group.load_balancer_access.id]
  depends_on = [module.vpc]
}

// TG
resource "aws_lb_target_group" "nginx-tg" {
  name                 = "${local.environment}-${local.product_name}-nginx-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 60
  target_type          = "instance"

  health_check {
    path = "/api/health-check"
    unhealthy_threshold = 5
    matcher = "200-499"
  }

  depends_on = [module.lb]
}

resource "aws_lb_listener_rule" "nginx" {
  listener_arn = aws_lb_listener.http.arn
  priority = 1

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.nginx-tg.arn
  }

  condition {
    host_header {
      values = ["mydomain.co.uk"]
    }
  }
}

// Listeners
resource "aws_lb_listener" "http" {
  load_balancer_arn = module.lb.lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = [module.lb]
}

module "cluster" {
  source = "../../modules/ecs-cluster"
  name = "${local.environment}-${local.product_name}"
  enable_container_insights = true
  tags = {
    Name = "${local.environment}-ecs-cluster"
  }
}

module "service" {
  source = "../../modules/ecs-service"
  region = local.region

  vpc_id = module.vpc.vpc_id

  environment = local.environment
  service_name = "nginx"
  service_image = "nginx:latest"
  service_port = "80"

  service_desired_count = "3"
  service_deployment_maximum_percent = "50"
  service_deployment_minimum_healthy_percent = "200"

  target_group_arn = aws_lb_target_group.nginx-tg.arn

  cluster_id = module.cluster.cluster_id
  cluster_service_role_arn = "arn:aws:iam::157140886817:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"

  depends_on = [module.lb]
}