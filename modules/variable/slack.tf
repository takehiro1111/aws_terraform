output "slack_workspace_id" {
  description = "個人用のSlackワークスペースID"
  value       = "T06PFGXUB2B" # personal 
  sensitive   = true
}

output "aws_alert_slack_channel_id" {
  description = "AWS系の通知用のSlackチャンネルID"
  value       = "C07GTL63RDJ" # aws_alert
  sensitive   = true
}

