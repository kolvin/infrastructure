variable "name" {
  description = "The service name."
  type        = string
}

variable "ecs_use_fargate" {
  description = "Whether to use Fargate for the task definition."
  default     = false
  type        = bool
}

variable "cluster_arn" {
  description = "ECS cluster arn for this task."
  type = string
}

variable "task_definition_arn" {
  description = "ECS cluster arn for this task."
  type = string
}

variable "tasks_desired_count" {
  description = "The number of instances of a task definition."
  default     = 1
  type        = number
}

variable "tasks_minimum_healthy_percent" {
  description = "Lower limit on the number of running tasks."
  default     = 100
  type        = number
}

variable "tasks_maximum_percent" {
  description = "Upper limit on the number of running tasks."
  default     = 200
  type        = number
}

// Networking
variable "ecs_subnet_ids" {
  description = "Subnet IDs for the ECS tasks."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether this instance should be accessible from the public internet. Default is false."
  default     = false
  type        = bool
}

variable "fargate_platform_version" {
  description = "The platform version on which to run your service. Only applicable when using Fargate launch type."
  default     = "LATEST"
  type        = string
}

// SG
variable "security_group_ids" {
  description = "A list of security groups the ECS service should also be added to."
  default     = []
  type        = list(string)
}

// ALB 
variable "associate_alb" {
  description = "Whether to associate an Application Load Balancer (ALB) with the ECS service."
  default     = false
  type        = bool
}

variable "associate_nlb" {
  description = "Whether to associate a Network Load Balancer (NLB) with the ECS service."
  default     = false
  type        = bool
}

variable "health_check_grace_period_seconds" {
  description = "Grace period within which failed health checks will be ignored at container start. Only applies to services with an attached loadbalancer."
  default     = null
  type        = number
}

// TG
variable "lb_target_groups" {
  description = "List of load balancer target group objects containing the lb_target_group_arn, container_port and container_health_check_port. The container_port is the port on which the container will receive traffic. The container_health_check_port is an additional port on which the container can receive a health check. The lb_target_group_arn is either Application Load Balancer (ALB) or Network Load Balancer (NLB) target group ARN tasks will register with."
  default     = []
  type = list(
    object({
      container_port              = number
      container_health_check_port = number
      lb_target_group_arn         = string
      }
    )
  )
}