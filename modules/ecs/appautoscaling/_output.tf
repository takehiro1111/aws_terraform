output "app_autoscaling_policy_arn_scale_out_cpu" {
  value = [for i in aws_appautoscaling_policy.this_scale_out_cpu[*].arn : i]
}

output "app_autoscaling_policy_arn_scale_in_cpu" {
  value = [for i in aws_appautoscaling_policy.this_scale_in_cpu[*].arn : i]
}

output "app_autoscaling_policy_arn_scale_out_memory" {
  value = [for i in aws_appautoscaling_policy.this_scale_out_memory[*].arn : i]
}

output "app_autoscaling_policy_arn_scale_in_memory" {
  value = [for i in aws_appautoscaling_policy.this_scale_in_memory[*].arn : i]
}
