provider "aws" {
  region  = var.region
}

// Network
module "vpc" {
  source                 = "github.com/terraform-aws-modules/terraform-aws-vpc"
  name                   = "${var.environment}-${var.product_name}-vpc"
  cidr                   = "${var.cdir_prefix}.0.0/16"
  azs                    = ["eu-west-1a", "eu-west-1c"]
  private_subnets        = ["${var.cdir_prefix}.1.0/24", "${var.cdir_prefix}.3.0/24"]
  public_subnets         = ["${var.cdir_prefix}.101.0/24", "${var.cdir_prefix}.103.0/24"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true

  tags = {
    Creator     = var.creator
    Environment = var.environment
    Product     = var.product_name
  }
}

// Security Groups
resource "aws_security_group" "load_balancer_access" {
  name        = "${var.environment}-${var.product_name}-lb-access"
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

  tags = {
    Name        = "${var.environment}-${var.product_name}-lb-access"
    Creator     = var.creator
    Environment = var.environment
    Product     = var.product_name
  }

  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "instance_http_access" {
  name        = "${var.environment}-${var.product_name}-instance-access"
  description = "Allow inbound from load balancer"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = [aws_security_group.load_balancer_access.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-${var.product_name}-instance-access"
    Creator     = var.creator
    Environment = var.environment
    Product     = var.product_name
  }

  vpc_id = module.vpc.vpc_id
}

// Allow SSH access
resource "aws_security_group" "ssh_access" {
  name        = "${var.environment}-${var.product_name}-ssh-access"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name        = "${var.environment}-${var.product_name}-ssh-access"
    Creator     = var.creator
    Environment = var.environment
    Product     = var.product_name
  }

  vpc_id = module.vpc.vpc_id
}

// Load Balancer
module "lb" {
  source = "../../modules/lb"

  name    = "${var.environment}-${var.product_name}-lb"
  subnets = module.vpc.public_subnets

  security_groups = [aws_security_group.load_balancer_access.id]
}

// HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = module.lb.lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tg.arn
  }
}

// Target Group
resource "aws_lb_target_group" "nginx-tg" {
  name                 = "${var.environment}-${var.product_name}-nginx-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 60
  target_type          = "instance"

  health_check {
    path                = "/api/health-check"
    unhealthy_threshold = 5
    matcher             = "200-499"
  }
}

// IAM Roles for ECS
data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name                = "ecs-agent"
  assume_role_policy  = data.aws_iam_policy_document.ecs_agent.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"]
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

// Base Image for ASG
data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

// Container host ASG
module "auto-scaling-hosts" {
  source           = "../../modules/asg"
  name             = "${var.environment}-${var.product_name}"
  max_size         = 2
  min_size         = 1
  desired_capacity = 1
  subnets          = module.vpc.public_subnets
  force_delete     = true

  iam_instance_profile_name = aws_iam_instance_profile.ecs_agent.name
  image_id                  = data.aws_ami.ecs.id
  instance_type             = "t2.micro"

  security_groups = [
    aws_security_group.instance_http_access.id,
    aws_security_group.ssh_access.id,
  ]

  associate_public_ip_address = true
  key_name                    = "throwaway"

  user_data = data.template_cloudinit_config.container-instances-config.rendered
}

// ECS Cluster
module "cluster" {
  source                    = "../../modules/ecs-cluster"
  name                      = "${var.environment}-${var.product_name}"
  enable_container_insights = true
  tags = {
    Name = "${var.environment}-ecs-cluster"
  }
}

// ECS Service
module "service" {
  source = "../../modules/ecs-service"
  region = var.region

  vpc_id = module.vpc.vpc_id

  environment   = var.environment
  service_name  = "nginx"
  service_image = "nginx:latest"
  service_port  = "80"

  service_desired_count = 1

  target_group_arn = aws_lb_target_group.nginx-tg.arn

  cluster_id               = module.cluster.cluster_id
  cluster_service_role_arn = "arn:aws:iam::157140886817:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
}
