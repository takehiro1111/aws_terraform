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

####################################################################
# Security Group
####################################################################
output "sg_id_mysql" {
  description = "MySQLのセキュリティグループID"
  value       = module.sg_mysql.security_group_id
}
