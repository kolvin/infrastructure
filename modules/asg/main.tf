resource "aws_autoscaling_group" "this" {
  name = var.name
  max_size = var.max_size
  min_size = var.min_size
  desired_capacity = var.desired_capacity
  vpc_zone_identifier = var.subnets
  launch_configuration = aws_launch_configuration.this.name
  health_check_type = var.health_check_type
  force_delete = var.force_delete

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "this" {
  name_prefix                 = "${var.name}-ecs-launch-configuration"
  image_id                    = var.image_id
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile_name
  associate_public_ip_address = var.associate_public_ip_address

  security_groups             = var.security_groups
  key_name                    = var.key_name
  user_data                   = var.user_data

  lifecycle {
    create_before_destroy = true
  }
}