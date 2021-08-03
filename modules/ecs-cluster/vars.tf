variable name {
  type        = string
  default     = ""
  description = "Name for this cluster"
}

variable enable_container_insights {
  type        = bool
  default     = false
  description = "Do you want to enable container insights for this cluster"
}

variable tags {
  type        = map(string)
  default     = {}
  description = "Tags for this cluster"
}
