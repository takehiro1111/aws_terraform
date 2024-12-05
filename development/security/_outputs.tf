####################################################################
# IAM
####################################################################
output "iam_role_arn_lambda_execute" {
  description = "Lambdaの実行権限に関する基本的なIAMロールのARN"
  value       = aws_iam_role.lambda_execute.arn
}

output "iam_role_arn_glue_crawler_vpc_flow_logs" {
  description = "VPC Flow LogsのGlue Crawlerに関するIAMロールのARN"
  value       = aws_iam_role.glue_crawler_vpc_flow_logs.arn
}

output "iam_role_arn_chatbot" {
  description = "Chatbotに関するIAMロールのARN"
  value       = aws_iam_role.chatbot.arn
}

output "iam_instance_profile_session_manager" {
  description = "EC2インスタンスプロファイルの名前"
  value       = aws_iam_instance_profile.session_manager.name
}

output "iam_role_arn_ecs_task_role_web" {
  description = "ECSタスクが他AWSサービスの権限をAssumeするためのIAMロールのARN"
  value       = module.ecs_task_role_web.iam_role_arn
}

output "iam_role_arn_ecs_task_execute_role_web" {
  description = "ECSタスク自体の実行に必要なIAMロールのARN"
  value       = module.ecs_task_execute_role_web.iam_role_arn
}

####################################################################
# Security Group
####################################################################
output "sg_id_mysql" {
  description = "MySQLのセキュリティグループID"
  value       = module.sg_mysql.security_group_id
}

output "sg_id_ecs" {
  description = "ECSのセキュリティグループID"
  value       = aws_security_group.ecs_stg.id
}

output "sg_id_alb" {
  description = "ALB用のセキュリティグループID"
  value       = aws_security_group.alb_stg.id
}

output "sg_id_vpce_for_ecs" {
  description = "VPCE用のセキュリティグループID"
  value       = aws_security_group.ecs_stg.id
}

output "sg_id_vpce_ssm" {
  description = "VPCE用のセキュリティグループID"
  value       = module.vpce_ssm.security_group_id
}

output "sg_id_ec2_ssm" {
  description = "EC2用のセキュリティグループID"
  value       = module.sg_ec2_ssm.security_group_id
}


