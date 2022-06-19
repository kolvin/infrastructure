roles = {
  terragrunt-github-ci = {
    description = "ci role used to manage resources in AWS"
    principals = [
      {
        entity = "Federated"
        values = ["arn:aws:iam::016272825626:oidc-provider/token.actions.githubusercontent.com"]
        assume_actions = ["sts:AssumeRoleWithWebIdentity"]
        conditions = [
          {
            test = "StringEquals",
            variable = "token.actions.githubusercontent.com:aud",
            values = ["sts.amazonaws.com"]
          }
        ]
      },
      {
        entity = "AWS"
        values = ["arn:aws:iam::016272825626:user/kolvin"]
        assume_actions = ["sts:AssumeRole"]
        conditions = []
      }
    ]
    instance_profile_enabled = true
    policy_documents = []
    managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    max_session_duration = 21600
    path = "/"
  }
}
