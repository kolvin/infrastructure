// Network
module "vpc" {
  source                 = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc?ref=v3.14.0"
  name                   = "${var.env}-${var.app_name}-vpc"
  cidr                   = "${var.cdir_prefix}.0.0/16"
  azs                    = ["eu-west-1a", "eu-west-1b"]
  private_subnets        = ["${var.cdir_prefix}.1.0/24", "${var.cdir_prefix}.3.0/24"]
  public_subnets         = ["${var.cdir_prefix}.101.0/24", "${var.cdir_prefix}.103.0/24"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true
}

// Security Groups
resource "aws_security_group" "load_balancer_access" {
  name        = "${var.env}-${var.app_name}-lb-access"
  description = "Global HTTP/S access"

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

  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "instance_http_access" {
  name        = "${var.env}-${var.app_name}-instance-access"
  description = "Allow inbound from load balancer"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_access.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.vpc.vpc_id
}

// Load Balancer
resource "aws_lb" "this" {
  name               = "${var.env}-${var.app_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_access.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
}

// ALB HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tg.arn
  }
}

// Target Group
resource "aws_lb_target_group" "nginx-tg" {
  name                 = "${var.env}-${var.app_name}-nginx-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 60
  target_type          = "instance"

  health_check {
    path                = "/"
    unhealthy_threshold = 5
    matcher             = "200-499"
  }
}

// Base Image for ASG
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

// Container host ASG
resource "aws_autoscaling_group" "this" {
  name                 = "${var.env}-${var.app_name}"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = module.vpc.public_subnets
  launch_configuration = aws_launch_configuration.this.name
  health_check_type    = "EC2"
  force_delete         = true

  lifecycle {
    create_before_destroy = true
  }
}

// Host launch config
resource "aws_launch_configuration" "this" {
  name_prefix                 = "${var.env}-${var.app_name}-ecs-launch-configuration-"
  image_id                    = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ecs_node_role.name
  associate_public_ip_address = false
  security_groups             = [aws_security_group.instance_http_access.id]
  key_name                    = ""
  user_data = templatefile("${local.user_data_dir}/cluster-config.sh", {
    ecs-cluster-name = aws_ecs_cluster.this.name
  })

  lifecycle {
    create_before_destroy = true
  }
}

// ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "${var.env}-${var.app_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

// ECS service definition
resource "aws_ecs_task_definition" "this" {
  family = "${var.env}-${var.app_name}"
  container_definitions = templatefile("${local.template_dir}/task_definition.json.tpl", {
    name    = var.app_name
    image   = var.app_image
    command = jsonencode(var.app_command)
    port    = var.app_port
  })
}

// ECS Service
resource "aws_ecs_service" "this" {
  name                               = "nginx"
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = 1
  iam_role                           = aws_iam_role.ecs_task_role.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 10
  force_new_deployment               = true
  load_balancer {
    target_group_arn = aws_lb_target_group.nginx-tg.arn
    container_name   = "nginx"
    container_port   = 80
  }
}
