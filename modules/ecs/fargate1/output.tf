output "ecs_service_name" {
  value = aws_ecs_service.this.name
}

output "ecs_service_id" {
  value = aws_ecs_service.this.id
}