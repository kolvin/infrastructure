/**
 * # AWS ECS Cluster
 *
 * This module only provides one resource which is the ecs clsuter.
 *
 * To run a production grade cluster you will need many more resources
 * 
 */
resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "false"
  }

  tags = var.tags
}