// Network
module "vpc" {
  source                 = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc?ref=v3.14.0"
  name                   = "${local.env}-${local.service}-vpc"
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
  name        = "${local.env}-${local.service}-lb-access"
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
  name        = "${local.env}-${local.service}-instance-access"
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
module "lb" {
  source = "../../../modules/lb"

  name    = "${local.env}-${local.service}-lb"
  subnets = module.vpc.public_subnets

  security_groups = [aws_security_group.load_balancer_access.id]
}

// ALB HTTP Listener
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
  name                 = "${local.env}-${local.service}-nginx-tg"
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
module "auto-scaling-hosts" {
  source                      = "../../../modules/asg"
  name                        = "${local.env}-${local.service}"
  max_size                    = 2
  min_size                    = 1
  desired_capacity            = 1
  subnets                     = module.vpc.public_subnets
  force_delete                = true
  iam_instance_profile_name   = aws_iam_instance_profile.ecs_node_role.name
  image_id                    = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.instance_http_access.id]
  associate_public_ip_address = false

  user_data = templatefile("${local.user_data_dir}/cluster-config.sh", {
    ecs-cluster-name = module.cluster.name
  })
}

// ECS Cluster
module "cluster" {
  source                    = "../../../modules/ecs-cluster"
  name                      = "${local.env}-${local.service}"
  enable_container_insights = true
}

// ECS Service
module "service" {
  source                = "../../../modules/ecs-service"
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  environment           = local.env
  service_name          = "nginx"
  service_image         = "nginx:latest"
  service_port          = "80"
  service_desired_count = 1
  target_group_arn      = aws_lb_target_group.nginx-tg.arn
  cluster_id            = module.cluster.id
  task_role             = aws_iam_role.ecs_task_role.arn
}
