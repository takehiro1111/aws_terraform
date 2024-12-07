#################################################################
# CloudWatch Logs
#################################################################
output "cw_log_group_name_public_instance" {
  description = "CloudWatch Log Group Name for Public Instance"
  value       = aws_cloudwatch_log_group.public_instance.name
}

output "cw_log_group_name_ecs_nginx" {
  description = "CloudWatch Log Group Name for ECS Nginx"
  value       = aws_cloudwatch_log_group.ecs_nginx.name
}

output "cw_log_group_name_lambda_s3_create" {
  description = "CloudWatch Log Group Name for ECS Nginx"
  value       = aws_cloudwatch_log_group.lambda_s3_create.name
}
