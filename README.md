# terraform-service

Terraform module to create an AWS ECS service using a provided container definitions.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster_name |  | string | - | yes |
| loadbalancer_container_name |  | string | - | yes |
| loadbalancer_container_port |  | string | - | yes |
| service_name |  | string | - | yes |
| target_group_arn |  | string | - | yes |
| task_definition_path |  | string | `data/task.json` | no |

## Outputs

| Name | Description |
|------|-------------|
| service_arn | ECS service ARN |
| task_definition_name | ECS service task definition name |
