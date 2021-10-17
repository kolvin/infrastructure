variable "region" {
  default     = "eu-west-1"
  type        = string
  description = "AWS Region context"
}

variable "profile" {
  default     = "personal"
  type        = string
  description = "Credentials Profile name"
}

variable "environment" {
  default     = "foo"
  type        = string
  description = "Environment name identifier"
}

variable "product_name" {
  default     = "bar"
  type        = string
  description = "Service Name"
}

variable "creator" {
  default     = "Terraform"
  type        = string
  description = "Who made me"
}

variable "cdir_prefix" {
  default     = "11.120"
  type        = string
  description = "Prefix to use for VPC creation"
}