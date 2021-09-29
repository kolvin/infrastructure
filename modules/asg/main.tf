resource "aws_autoscaling_group" "this" {
  name = var.name
  max_size = var.max_size
  min_size = var.min_size
  desired_capacity = var.desired_capacity
  vpc_zone_identifier = var.vpc_zone_identifier
  launch_configuration = aws_launch_configuration.this.name
  health_check_type = var.health_check_type
}

resource "aws_launch_configuration" "this" {
  name_prefix                 = "${var.name}-ecs-launch-configuration"
  image_id                    = var.image_id
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile_name
  associate_public_ip_address = var.associate_public_ip_address

  security_groups             = var.security_groups
  key_name                    = var.key_name
}