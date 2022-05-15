<!-- BEGIN_TF_DOCS -->
 # AWS ECS Service

This module creates AWS resources:
 - ECS service
 - ECS task definition

And it requires the following resources:
 - Existing ECS Cluster
 - Existing VPC
 - Existing ELB
 - Service Role

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.15.0 |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.cluster_default_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_default_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [template_file.service](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | The ID of the ECS cluster in which to deploy the service. | `string` | n/a | yes |
| <a name="input_cluster_service_role_arn"></a> [cluster\_service\_role\_arn](#input\_cluster\_service\_role\_arn) | The ARN of the IAM role to provide to ECS to manage the service. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | An environment for this instantiation. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region into which to deploy this service. | `string` | n/a | yes |
| <a name="input_service_image"></a> [service\_image](#input\_service\_image) | The docker image (including version) to deploy. | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The name of the service being created. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id in which to deploy this service. | `string` | n/a | yes |
| <a name="input_associate_default_security_group"></a> [associate\_default\_security\_group](#input\_associate\_default\_security\_group) | Whether or not to create and associate a default security group for the tasks created by this service ("yes" or "no"). Defaults to "yes". Only applicable when service\_task\_network\_mode is "awsvpc". | `string` | `"yes"` | no |
| <a name="input_attach_to_load_balancer"></a> [attach\_to\_load\_balancer](#input\_attach\_to\_load\_balancer) | Whether or not this service should attach to a load balancer ("yes" or "no"). | `string` | `"yes"` | no |
| <a name="input_default_security_group_egress_cidrs"></a> [default\_security\_group\_egress\_cidrs](#input\_default\_security\_group\_egress\_cidrs) | The CIDRs accessible from containers when using the default security group. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_default_security_group_ingress_cidrs"></a> [default\_security\_group\_ingress\_cidrs](#input\_default\_security\_group\_ingress\_cidrs) | The CIDRs allowed access to containers when using the default security group. | `list(string)` | <pre>[<br>  "10.0.0.0/8"<br>]</pre> | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Whether or not to force a new deployment of the service ("yes" or "no"). Defaults to "no". | `string` | `"no"` | no |
| <a name="input_include_default_egress_rule"></a> [include\_default\_egress\_rule](#input\_include\_default\_egress\_rule) | Whether or not to include the default egress rule in the default security group for the tasks created by this service ("yes" or "no"). Defaults to "yes". Only applicable when service\_task\_network\_mode is "awsvpc". | `string` | `"yes"` | no |
| <a name="input_include_default_ingress_rule"></a> [include\_default\_ingress\_rule](#input\_include\_default\_ingress\_rule) | Whether or not to include the default ingress rule in the default security group for the tasks created by this service ("yes" or "no"). Defaults to "yes". Only applicable when service\_task\_network\_mode is "awsvpc". | `string` | `"yes"` | no |
| <a name="input_placement_constraints"></a> [placement\_constraints](#input\_placement\_constraints) | A list of placement constraints for the service. | `list(map(string))` | `[]` | no |
| <a name="input_scheduling_strategy"></a> [scheduling\_strategy](#input\_scheduling\_strategy) | The scheduling strategy to use for this service ("REPLICA" or "DAEMON"). | `string` | `"REPLICA"` | no |
| <a name="input_service_command"></a> [service\_command](#input\_service\_command) | The command to run to start the container. | `list(string)` | `[]` | no |
| <a name="input_service_deployment_maximum_percent"></a> [service\_deployment\_maximum\_percent](#input\_service\_deployment\_maximum\_percent) | The maximum percentage of the desired count that can be running. | `number` | `200` | no |
| <a name="input_service_deployment_minimum_healthy_percent"></a> [service\_deployment\_minimum\_healthy\_percent](#input\_service\_deployment\_minimum\_healthy\_percent) | The minimum healthy percentage of the desired count to keep running. | `number` | `100` | no |
| <a name="input_service_desired_count"></a> [service\_desired\_count](#input\_service\_desired\_count) | The desired number of tasks in the service. | `number` | `1` | no |
| <a name="input_service_elb_name"></a> [service\_elb\_name](#input\_service\_elb\_name) | The name of the ELB to configure to point at the service containers. | `string` | `""` | no |
| <a name="input_service_health_check_grace_period_seconds"></a> [service\_health\_check\_grace\_period\_seconds](#input\_service\_health\_check\_grace\_period\_seconds) | The number of seconds to wait for the service to start up before starting load balancer health checks. | `number` | `10` | no |
| <a name="input_service_port"></a> [service\_port](#input\_service\_port) | The port the containers will be listening on. | `string` | `""` | no |
| <a name="input_service_role_arn"></a> [service\_role\_arn](#input\_service\_role\_arn) | The ARN of the service task role to use. | `string` | `""` | no |
| <a name="input_service_task_network_mode"></a> [service\_task\_network\_mode](#input\_service\_task\_network\_mode) | The network mode used for the containers in the task. | `string` | `"bridge"` | no |
| <a name="input_service_task_pid_mode"></a> [service\_task\_pid\_mode](#input\_service\_task\_pid\_mode) | The process namespace used for the containers in the task. | `string` | `null` | no |
| <a name="input_service_volumes"></a> [service\_volumes](#input\_service\_volumes) | A list of volumes to make available to the containers in the service. | `list(map(string))` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The subnets IDs in which to create ENIs when the service task network mode is "awsvpc". | `list(string)` | `[]` | no |
| <a name="input_target_container_name"></a> [target\_container\_name](#input\_target\_container\_name) | The name of the container to which the load balancer should route traffic. Defaults to the service\_name. | `string` | `""` | no |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | The arn of the target group to point at the service containers. | `string` | `""` | no |
| <a name="input_target_port"></a> [target\_port](#input\_target\_port) | The port to which the load balancer should route traffic. Defaults to the service\_port. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | The ID of the service |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | The ARN of the service task definition |

# License
GNU GENERAL PUBLIC LICENSE. See [LICENSE](../../LICENSE) for full details.
<!-- END_TF_DOCS -->