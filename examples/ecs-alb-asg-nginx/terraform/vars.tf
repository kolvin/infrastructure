variable "region" {
  default     = "eu-west-1"
  type        = string
  description = "AWS Region context"
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