variable region {
  type        = string
  description = "The region into which to deploy this service."
}

variable vpc_id {
  type        = string
  description = "The VPC into which to deploy this service."
}

variable subnet_ids {
  type        = list(string)
  description = "The subnets IDs in which to create ENIs when the service task network mode is \"awsvpc\"."
  default     = []
}

variable environment {
  type        = string
  description = "An environment for this instantiation."
}

variable service_name {
  type        = string
  description = "The name of the service being created."
}

variable service_image {
  type        = string
  description = "The docker image (including version) to deploy."
  default     = ""
}

variable service_command {
  type        = list(string)
  description = "The command to run to start the container."
  default     = []
}

variable service_port {
  type        = string
  description = "The port the containers will be listening on."
  default     = ""
}

variable service_task_network_mode {
  type        = string
  description = "The network mode used for the containers in the task."
  default     = "bridge"
}

variable service_task_pid_mode {
  type        = string
  description = "The process namespace used for the containers in the task."
  default     = null
}

variable service_desired_count {
  type        = number
  description = "The desired number of tasks in the service."
  default     = 1
}

variable service_deployment_maximum_percent {
  type        = number
  description = "The maximum percentage of the desired count that can be running."
  default     = 200
}

variable service_deployment_minimum_healthy_percent {
  type        = number
  description = "The minimum healthy percentage of the desired count to keep running."
  default     = 50
}

variable service_health_check_grace_period_seconds {
  type        = number
  description = "The number of seconds to wait for the service to start up before starting load balancer health checks."
  default     = 10
}

variable attach_to_load_balancer {
  type        = string
  description = "Whether or not this service should attach to a load balancer (\"yes\" or \"no\")."
  default     = "yes"
}

variable service_elb_name {
  type        = string
  description = "The name of the ELB to configure to point at the service containers."
  default     = ""
}

variable target_group_arn {
  type        = string
  description = "The arn of the target group to point at the service containers."
  default     = ""
}

variable target_container_name {
  type        = string
  description = "The name of the container to which the load balancer should route traffic. Defaults to the service_name."
  default     = ""
}

variable target_port {
  type        = string
  description = "The port to which the load balancer should route traffic. Defaults to the service_port."
  default     = ""
}

variable register_in_service_discovery {
  type        = string
  description = "Whether or not this service should be registered in service discovery (\"yes\" or \"no\")."
  default     = "no"
}

variable service_discovery_create_registry {
  type        = string
  description = "Whether or not to create a service discovery registry for this service (\"yes\" or \"no\")."
  default     = "yes"
}

variable associate_default_security_group {
  type        = string
  description = "Whether or not to create and associate a default security group for the tasks created by this service (\"yes\" or \"no\"). Defaults to \"yes\". Only applicable when service_task_network_mode is \"awsvpc\"."
  default     = "yes"
}

variable include_default_ingress_rule {
  type        = string
  description = "Whether or not to include the default ingress rule in the default security group for the tasks created by this service (\"yes\" or \"no\"). Defaults to \"yes\". Only applicable when service_task_network_mode is \"awsvpc\"."
  default     = "yes"
}

variable include_default_egress_rule {
  type        = string
  description = "Whether or not to include the default egress rule in the default security group for the tasks created by this service (\"yes\" or \"no\"). Defaults to \"yes\". Only applicable when service_task_network_mode is \"awsvpc\"."
  default     = "yes"
}

variable default_security_group_ingress_cidrs {
  type        = list(string)
  description = "The CIDRs allowed access to containers when using the default security group."
  default     = ["10.0.0.0/8"]
}

variable default_security_group_egress_cidrs {
  type        = list(string)
  description = "The CIDRs accessible from containers when using the default security group."
  default     = ["0.0.0.0/0"]
}

variable service_role_arn {
  type        = string
  description = "The ARN of the service task role to use."
  default     = ""
}

variable service_volumes {
  type        = list(map(string))
  description = "A list of volumes to make available to the containers in the service."
  default     = []
}

variable scheduling_strategy {
  type        = string
  description = "The scheduling strategy to use for this service (\"REPLICA\" or \"DAEMON\")."
  default     = "REPLICA"
}

variable placement_constraints {
  type        = list(map(string))
  description = "A list of placement constraints for the service."
  default     = []
}

variable cluster_id {
  type        = string
  description = "The ID of the ECS cluster in which to deploy the service."
}

variable cluster_service_role_arn {
  type        = string
  description = "The ARN of the IAM role to provide to ECS to manage the service."
}

variable force_new_deployment {
  type        = string
  description = "Whether or not to force a new deployment of the service (\"yes\" or \"no\"). Defaults to \"no\"."
  default     = "no"
}
