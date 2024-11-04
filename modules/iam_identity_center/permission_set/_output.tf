output "permission_set_arn" {
  description = "PermissionSetのARNを参照するための設定"
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.arn }
}
