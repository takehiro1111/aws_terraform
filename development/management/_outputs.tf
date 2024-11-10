output "cw_log_group_name_public_instance" {
  description = "CloudWatch Log Group Name for Public Instance"
  value       = aws_cloudwatch_log_group.public_instance.name
}
