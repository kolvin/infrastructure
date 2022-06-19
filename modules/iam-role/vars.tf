variable "roles" {
  type = map(object({
    description = string
    principals = list(object({
      entity         = string
      values         = list(string)
      assume_actions = list(string)
      conditions = list(object({
        test     = string
        variable = string
        values   = list(string)
      }))
    }))
    instance_profile_enabled = bool
    policy_documents         = list(string) # List of JSON IAM policy documents
    managed_policy_arns      = list(string) # List of IAM policy arns
    max_session_duration     = number
    path                     = string
  }))
  description = "Collection of roles for this module to manage"
}