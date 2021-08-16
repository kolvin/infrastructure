locals {
  awslogs_group         = var.logs_cloudwatch_group == "" ? "/ecs/${var.environment}/${var.name}" : var.logs_cloudwatch_group
  target_container_name = var.target_container_name == "" ? "${var.name}-${var.environment}" : var.target_container_name
  cloudwatch_alarm_name = var.cloudwatch_alarm_name == "" ? "${var.name}-${var.environment}" : var.cloudwatch_alarm_name

  # for each target group, allow ingress from the alb to ecs container port
  lb_ingress_container_ports = distinct(
    [
      for lb_target_group in var.lb_target_groups : lb_target_group.container_port
    ]
  )

  # for each target group, allow ingress from the alb to ecs healthcheck port
  # if it doesn't collide with the container ports
  lb_ingress_container_health_check_ports = tolist(
    setsubtract(
      [
        for lb_target_group in var.lb_target_groups : lb_target_group.container_health_check_port
      ],
      local.lb_ingress_container_ports,
    )
  )
}

locals {
  ecs_service_launch_type  = var.ecs_use_fargate ? "FARGATE" : "EC2"
  fargate_platform_version = var.ecs_use_fargate ? var.fargate_platform_version : null

  ecs_service_ordered_placement_strategy = {
    EC2 = [
      {
        type  = "spread"
        field = "attribute:ecs.availability-zone"
      },
      {
        type  = "spread"
        field = "instanceId"
      },
    ]
    FARGATE = []
  }

  ecs_service_placement_constraints = {
    EC2 = [
      {
        type = "distinctInstance"
      },
    ]
    FARGATE = []
  }
}


resource "aws_ecs_service" "this" {
  name    = var.name
  cluster = var.cluster_arn

  launch_type      = local.ecs_service_launch_type
  platform_version = local.fargate_platform_version

  task_definition = var.task_definition_arn

  desired_count                      = var.tasks_desired_count
  deployment_minimum_healthy_percent = var.tasks_minimum_healthy_percent
  deployment_maximum_percent         = var.tasks_maximum_percent


  dynamic "ordered_placement_strategy" {
    for_each = local.ecs_service_ordered_placement_strategy[local.ecs_service_launch_type]

    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  dynamic "placement_constraints" {
    for_each = local.ecs_service_placement_constraints[local.ecs_service_launch_type]

    content {
      type = placement_constraints.value.type
    }
  }

  network_configuration {
    subnets          = var.ecs_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.associate_alb || var.associate_nlb ? var.lb_target_groups : []
    content {
      container_name   = local.target_container_name
      target_group_arn = load_balancer.value.lb_target_group_arn
      container_port   = load_balancer.value.container_port
    }
  }

  health_check_grace_period_seconds = var.associate_alb || var.associate_nlb ? var.health_check_grace_period_seconds : null

  # lifecycle {
  #   ignore_changes = [task_definition]
  # }
}