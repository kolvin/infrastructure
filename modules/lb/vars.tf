variable name {
  type        = string
  description = "The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. If not specified, Terraform will autogenerate a name beginning with tf-lb"
}

variable internal {
  type        = bool
  default     = false
  description = "If true, the LB will be internal."
}

variable enable_deletion_protection {
  type        = bool
  default     = false
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false"
}

variable load_balancer_type {
  type        = string
  default     = "application"
  description = "The type of load balancer to create. Possible values are application, gateway, or network. The default value is application"
}

variable security_groups {
  type        = list(string)
  default     = []
  description = "A list of security group IDs to assign to the LB. Only valid for Load Balancers of type Application"
}

variable subnets {
  type        = list(string)
  default     = []
  description = "A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value for load balancers of type network will force a recreation of the resource"
}

variable access_logs {
  type = list(map(string))
  default = []
  description = "An Access Logs block"
}

variable tags {
  type        = map(string)
  default     = {}
  description = "Tags for this LB"
}