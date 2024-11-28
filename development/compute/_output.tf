#########################################################################################
# ECS
#########################################################################################
output "ecs_cluster_arn_web" {
  description = "web用のECSクラスターのARN"
  value = aws_ecs_cluster.web.arn
}

output "ecs_cluster_name_web" {
  description = "web用のECSクラスターのName"
  value = aws_ecs_cluster.web.name
}

output "ecs_service_name_web_nginx" {
  description = "web用のECSサービスのName"
  value = aws_ecs_service.web_nginx.name
}
