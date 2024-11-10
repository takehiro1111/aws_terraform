####################################################################
# IAM
####################################################################
output "lambda_execute_role_arn" {
  description = "Lambdaの実行権限に関する基本的なIAMロール"
  value       = aws_iam_role.lambda_execute.arn
}

####################################################################
# Security Group
####################################################################
output "sg_id_mysql" {
  description = "MySQLのセキュリティグループID"
  value       = module.sg_mysql.security_group_id
}
