output task_definition_arn {
  sensitive   = false
  value = aws_ecs_task_definition.this.arn
  description = "The ARN of the service task definition"
}

output service_id {
  sensitive   = false
  value = aws_ecs_service.this.id
  description = "The ID of the service"
}