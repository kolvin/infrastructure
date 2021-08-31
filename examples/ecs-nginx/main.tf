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

module lb {
  source = "../../modules/lb"

  name = "test"
  subnets = module.vpc.public_subnets

  depends_on = [module.vpc]
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

  service_elb_name = "..."

  cluster_id = module.cluster.cluster_id
  cluster_service_role_arn = "arn:aws:iam::"
}