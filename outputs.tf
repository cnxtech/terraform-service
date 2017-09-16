output "service_arn" {
  description = "ECS service ARN"
  value       = "${aws_ecs_service.main.id}"
}

output "task_definition_name" {
  description = "ECS service task definition name"
  value       = "${aws_ecs_task_definition.main.family}"
}
