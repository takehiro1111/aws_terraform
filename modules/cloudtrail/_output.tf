output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.this[0].arn
}
