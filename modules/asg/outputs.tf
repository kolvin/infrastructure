output autoscaling_group_name {
  sensitive   = false
  value = aws_autoscaling_group.this.name
  description = "The name of this auto scaling group"
}

output autoscaling_group_max_size {
  sensitive   = false
  value = aws_autoscaling_group.this.max_size
  description = "The maximum size of this auto scaling group"
}

output autoscaling_group_min_size {
  sensitive   = false
  value = aws_autoscaling_group.this.min_size
  description = "The minimum size of this auto scaling group"
}

output autoscaling_group_desired_capacity {
  sensitive   = false
  value = aws_autoscaling_group.this.desired_capacity
  description = "The desired capacity of this auto scaling group"
}

output autoscaling_group_health_check_type {
  sensitive   = false
  value = aws_autoscaling_group.this.health_check_type
  description = "The health check type of this auto scaling group"
}

output autoscaling_group_vpc_id {
  sensitive   = false
  value = aws_autoscaling_group.this.vpc_zone_identifier
  description = "The VPC ID of this auto scaling group"
}

// Launch Configuration

output launch_configuration_name {
  sensitive   = false
  value = aws_launch_configuration.this.name_prefix
  description = "The name of the groups launch configuration"
}

output launch_configuration_image_id {
  sensitive   = false
  value = aws_launch_configuration.this.image_id
  description = "Image ID of the groups launch configuration"
}

output launch_configuration_instance_type {
  sensitive   = false
  value = aws_launch_configuration.this.instance_type
  description = "Instance type of the groups launch configuration"
}

output launch_configuration_iam_instance_profile {
  sensitive   = false
  value = aws_launch_configuration.this.iam_instance_profile
  description = "Iam instance profile of the groups launch configuration"
}

output launch_configuration_associate_public_ip_address {
  sensitive   = false
  value = aws_launch_configuration.this.associate_public_ip_address
  description = "Associate a public ip address with an instance launched from this configuration"
}

output launch_configuration_security_groups {
  sensitive   = false
  value = aws_launch_configuration.this.security_groups
  description = "Security groups of the groups launch configuration"
}

output launch_configuration_key_name {
  sensitive   = false
  value = aws_launch_configuration.this.key_name
  description = "Instance key name for this launch configuration"
}