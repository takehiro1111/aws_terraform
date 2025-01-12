##########################################################
# ID of S3 Bucket
##########################################################
output "s3_bucket_id_config_audit_log" {
  description = "Config S3Bucket"
  value       = module.s3_bucket_config_audit_log.s3_bucket_id
}

output "s3_bucket_id_cloudtrail_audit_log" {
  description = "CloudTrail S3Bucket"
  value       = module.s3_bucket_cloudtrail_audit_log.s3_bucket_id
}

##########################################################
# ARN of S3 Bucket
##########################################################
output "s3_bucket_arn_config_audit_log" {
  description = "Config S3Bucket"
  value       = module.s3_bucket_config_audit_log.s3_bucket_arn
}

locals {
  name = toset(["test2-13"])
}

resource "aws_iam_user" "test" {
  for_each = local.name
  name     = each.key
}
