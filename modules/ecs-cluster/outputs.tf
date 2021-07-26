/**
 * # License
 * GNU GENERAL PUBLIC LICENSE. See [LICENSE](../../LICENSE) for full details.
 */

output "id" {
  value       = aws_ecs_cluster.this.id
  sensitive   = false
  description = "ID of this ecs cluster"
  depends_on  = []
}

output "arn" {
  value       = aws_ecs_cluster.this.arn
  sensitive   = false
  description = "ARN of this ecs cluster"
  depends_on  = []
}

output "name" {
  value       = aws_ecs_cluster.this.name
  sensitive   = false
  description = "Name of this ecs cluster"
  depends_on  = []
}