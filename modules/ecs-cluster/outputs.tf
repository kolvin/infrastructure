output cluster_id {
  sensitive   = false
  value       = aws_ecs_cluster.this.id
  description = "ID of this ECS cluster"
}

output cluster_arn {
  sensitive   = false
  value       = aws_ecs_cluster.this.arn
  description = "ARN of this ECS cluster"
}

output cluster_name {
  sensitive   = false
  value       = aws_ecs_cluster.this.name
  description = "Name of this ECS cluster"
}