<!-- BEGIN_TF_DOCS -->
# AWS ECS Cluster

This module only provides one resource which is the ecs clsuter.

To run a production grade cluster you will need many more resources

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.51.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | Do you want to enable container insights for this cluster | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for this cluster | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for this cluster | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of this ecs cluster |
| <a name="output_id"></a> [id](#output\_id) | ID of this ecs cluster |
| <a name="output_name"></a> [name](#output\_name) | Name of this ecs cluster |

# License
GNU GENERAL PUBLIC LICENSE. See [LICENSE](../../LICENSE) for full details.
<!-- END_TF_DOCS -->