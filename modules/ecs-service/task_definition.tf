resource "aws_ecs_task_definition" "this" {
  family                = "${var.environment}-${var.service_name}"
  container_definitions = templatefile("${path.module}/service.json.tpl", {
    name      = var.service_name
    image     = var.service_image
    command   = jsonencode(var.service_command)
    port      = var.service_port
  })

  network_mode = var.service_task_network_mode
  pid_mode     = var.service_task_pid_mode

  task_role_arn = var.service_role_arn

  dynamic "volume" {
    for_each = var.service_volumes

    content {
      name      = volume.value.name
      host_path = lookup(volume.value, "host_path", null)
    }
  }
}
