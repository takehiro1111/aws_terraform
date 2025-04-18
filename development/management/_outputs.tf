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

output "cw_log_group_name_ecs_locust" {
  description = "CloudWatch Log Group Name for ECS LOCUST"
  value       = aws_cloudwatch_log_group.ecs_locust.name
}

output "cw_log_group_name_lambda_s3_create" {
  description = "CloudWatch Log Group Name for ECS Nginx"
  value       = aws_cloudwatch_log_group.lambda_s3_create.name
}

########################################################################
# SNS
########################################################################
output "sns_topic_arn_ecs_cw_alert" {
  description = "ECSの負荷に関する通知"
  value       = module.sns_notify_chatbot_ecs_cw_alert.topic_arn
}

########################################################################
# Parameter Store
########################################################################
output "ssm_parameter_store_my_ip" {
  description = "自宅のGIP"
  value       = data.aws_ssm_parameter.my_ip.value
  sensitive   = true
}
