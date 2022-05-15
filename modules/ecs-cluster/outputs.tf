output id {
  sensitive   = false
  value       = aws_ecs_cluster.this.id
  description = "ID of this ECS cluster"
}

output arn {
  sensitive   = false
  value       = aws_ecs_cluster.this.arn
  description = "ARN of this ECS cluster"
}

output name {
  sensitive   = false
  value       = aws_ecs_cluster.this.name
  description = "Name of this ECS cluster"
}