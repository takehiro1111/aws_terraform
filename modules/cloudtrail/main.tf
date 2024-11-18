##################################################################
# Cloud Trail
##################################################################
#trivy:ignore:AVD-AWS-0015 // (HIGH): CloudTrail does not use a customer managed key to encrypt the logs.
resource "aws_cloudtrail" "this" {
  count = var.create ? 1 : 0

  name                          = var.name
  s3_bucket_name                = var.s3_bucket_name
  cloud_watch_logs_group_arn    = var.cloud_watch_logs_group_arn
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  enable_logging                = var.enable_logging
  enable_log_file_validation    = var.enable_log_file_validation
  is_organization_trail         = var.is_organization_trail

  dynamic "insight_selector" {
    for_each = {
      for k, v in var.insight_selectors : k => v
      if v.enabled
    }
    content {
      insight_type = insight_selector.value.insight_type
    }
  }
  tags = {
    Name = var.name
  }
}

##################################################################
# CloudWatch Logs
##################################################################
resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_cw_log_group ? 1 : 0
  name              = "cloudtrail/${aws_cloudtrail.this[count.index].home_region}/${var.name}"
  log_group_class   = "INFREQUENT_ACCESS" // コストをかけたくないため。
  skip_destroy      = false               // Terraform管理から除外 = ロググループも削除
  retention_in_days = 1                   // 保管コストをかけたくないため。
}
