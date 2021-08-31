output task_definition_arn {
  description = "The ARN of the service task definition"
  value = aws_ecs_task_definition.this.arn
}

output service_id {
  description = "The ID of the service"
  value = aws_ecs_service.this.id
}