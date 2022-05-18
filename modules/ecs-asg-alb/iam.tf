// ECS node IAM Role
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_node_role" {
  statement {
    sid = "allowNodeCommsWithCluster"

    actions = [
      "ec2:DescribeTags",
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:UpdateContainerInstancesState",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "ecs_node_role" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_role_policy" "ecs_node_role_policy" {
  name   = "ecs-node-role"
  role   = aws_iam_role.ecs_node_role.id
  policy = data.aws_iam_policy_document.ecs_node_role.json
}

resource "aws_iam_instance_profile" "ecs_node_role" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_node_role.name
}

// ECS Task IAM ROLE
data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    sid = "ECSTaskManagement"

    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DeleteNetworkInterface",
      "ec2:DeleteNetworkInterfacePermission",
      "ec2:Describe*",
      "ec2:DetachNetworkInterface",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "route53:ChangeResourceRecordSets",
      "route53:CreateHealthCheck",
      "route53:DeleteHealthCheck",
      "route53:Get*",
      "route53:List*",
      "route53:UpdateHealthCheck",
      "servicediscovery:DeregisterInstance",
      "servicediscovery:Get*",
      "servicediscovery:List*",
      "servicediscovery:RegisterInstance",
      "servicediscovery:UpdateInstanceCustomHealthStatus"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "AutoScaling"

    actions = [
      "autoscaling:Describe*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "AutoScalingManagement"

    actions = [
      "autoscaling:DeletePolicy",
      "autoscaling:PutScalingPolicy",
      "autoscaling:SetInstanceProtection",
      "autoscaling:UpdateAutoScalingGroup"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "Null"
      variable = "autoscaling:ResourceTag/AmazonECSManaged"
      values   = [false]
    }
  }

  statement {
    sid = "AutoScalingPlanManagement"

    actions = [
      "autoscaling-plans:CreateScalingPlan",
      "autoscaling-plans:DeleteScalingPlan",
      "autoscaling-plans:DescribeScalingPlans"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "CWAlarmManagement"

    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "ECSTagging"

    actions = [
      "ec2:CreateTags"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "CWLogGroupManagement"

    actions = [
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:PutRetentionPolicy"
    ]

    resources = [
      "arn:aws:logs:*:*:log-group:/aws/ecs/*"
    ]
  }

  statement {
    sid = "ExecuteCommandSessionManagement"

    actions = [
      "ssm:DescribeSessions"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "ExecuteCommand"

    actions = [
      "ssm:StartSession"
    ]

    resources = [
      "arn:aws:ecs:*:*:task/*",
      "arn:aws:ssm:*:*:document/AmazonECS-ExecuteInteractiveCommand"
    ]
  }

}

data "aws_iam_policy_document" "task-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs-task"
  assume_role_policy = data.aws_iam_policy_document.task-assume-role-policy.json
}

resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name   = "ecs-task-role"
  role   = aws_iam_role.ecs_task_role.id
  policy = data.aws_iam_policy_document.ecs_task_role.json
}