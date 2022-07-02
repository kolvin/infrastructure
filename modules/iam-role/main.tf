data "aws_iam_policy_document" "assume_role" {
  for_each = { for k, role in var.roles : k => role if length(role.principals) > 0 }

  dynamic "statement" {
    for_each = each.value.principals

    content {
      effect  = "Allow"
      actions = statement.value.assume_actions

      principals {
        type        = statement.value.entity
        identifiers = statement.value.values
      }

      dynamic "condition" {
        for_each = statement.value.conditions

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

data "aws_iam_policy_document" "assume_role_aggregated" {
  for_each = { for k, role in var.roles : k => role if length(role.principals) > 0 }

  override_policy_documents = [data.aws_iam_policy_document.assume_role[each.key].json]
}

resource "aws_iam_role" "this" {
  for_each             = var.roles
  name                 = each.key
  description          = each.value.description
  path                 = each.value.path
  max_session_duration = each.value.max_session_duration
  assume_role_policy   = length(each.value.principals) > 0 ? data.aws_iam_policy_document.assume_role_aggregated[each.key].json : null
}

resource "aws_iam_instance_profile" "this" {
  for_each = { for k, role in var.roles : k => role if role.instance_profile_enabled }
  name     = each.key
  role     = aws_iam_role.this[each.key].name
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = local.role_managed_policy_arns
  role       = each.value.role_name
  policy_arn = each.value.policy_arn
}