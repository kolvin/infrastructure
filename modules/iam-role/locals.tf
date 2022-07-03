locals {
  additional_tags = {}
  role_managed_policy_arns = {
    for assoc in flatten(
      [for role_name, details in var.roles :
        [for policy in details.managed_policy_arns :
          {
            "role_name"  = role_name
            "policy_arn" = policy
          }
        ]
      ]
    ) : "${assoc.role_name}-${assoc.policy_arn}" => assoc
  }
}