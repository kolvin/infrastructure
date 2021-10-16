data "template_cloudinit_config" "container-instances-config" {
  part {
    content = data.template_file.ecs-cluster.rendered
  }

  part {
    content = data.template_file.container-instance-hostname.rendered
  }

  part {
    content = data.template_file.server-provision.rendered
  }

  part {
    content = data.template_file.rex-ray.rendered
  }
}

data "template_file" "server-provision" {
  template = file("${path.module}/../../user_data/server_provisions.sh")
}

data "template_file" "docker-compose-provision" {
  template = file("${path.module}/../../user_data/docker_compose_provisions.sh")
}

data "template_file" "ecs-cluster" {
  template = file("${path.module}/../../user_data/cluster-config.sh")

  vars = {
    ecs-cluster-name = module.cluster.cluster_name
  }
}

data "template_file" "container-instance-hostname" {
  template = file("${path.module}/../../user_data/set_hostname.sh")

  vars = {
    hostname = "${var.environment}-${var.product_name}-container-instance"
  }
}

data "template_file" "rex-ray" {
  template = file("${path.module}/../../user_data/rexray-ebs.sh")

  vars = {
    region = var.region
  }
}


