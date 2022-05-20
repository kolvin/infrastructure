variable "env" {
  default     = ""
  type        = string
  description = "Environment identifier"
}

variable "app_name" {
  default     = ""
  type        = string
  description = "Name of application"
}

variable "app_image" {
  default     = ""
  type        = string
  description = "Container image of application"
}

variable "app_port" {
  default     = 0
  type        = number
  description = "Container port"
}

variable "app_command" {
  default     = []
  type        = list(any)
  description = "Container image command"
}

variable "cdir_prefix" {
  default     = "11.120"
  type        = string
  description = "Prefix to use for VPC creation"
}

variable "tags" {
  description = "Common tags to apply to all AWS resources"
  type        = map(any)
  default     = {}
}