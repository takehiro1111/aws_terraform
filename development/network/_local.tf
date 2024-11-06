
/* 
 * CloudFront
 */
// CloudFrontのカスタムエラーレスポンス
locals {
  custom_error_responses = [
    {
      error_caching_min_ttl = 10
      error_code            = 500
      response_code         = 500
      response_page_path    = "/maintenance/maintenance.html"
    },
    {
      error_caching_min_ttl = 10
      error_code            = 501
      response_code         = 501
      response_page_path    = "/maintenance/maintenance.html"
    },
    {
      error_caching_min_ttl = 10
      error_code            = 502
      response_code         = 502
      response_page_path    = "/maintenance/maintenance.html"
    },
    {
      error_caching_min_ttl = 10
      error_code            = 504
      response_code         = 504
      response_page_path    = "/maintenance/maintenance.html"
    }
  ]

  // メンテモードをtrueにする場合は503エラーのカスタムエラーレスポンスを作成する。
  conditional_custom_error_responses = var.full_maintenance || var.half_maintenance ? [
    {
      error_caching_min_ttl = 10
      error_code            = 503
      response_code         = 503
      response_page_path    = "/maintenance/maintenance.html"
    }
  ] : []
}

// CloudFrontのロギング用バケットのPrefix設定
locals {
  processing            = replace(module.value.cdn_takehiro1111_com, ".", "_")
  logging_config_prefix = replace(local.processing, "-", "_")
}

/* 
 * S3
 */
// ライフサイクルポリシーをdynamicブロックで再利用
locals {
  lifecycle_configuration = [
    {
      id     = local.logging_config_prefix
      status = "Enabled"
      prefix = local.logging_config_prefix

      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
        { days = 180, storage_class = "GLACIER" },
        { days = 365, storage_class = "DEEP_ARCHIVE" }
      ]

      nonself_version_transition = {
        newer_nonself_versions = 1
        nonself_days           = 30
        storage_class             = "DEEP_ARCHIVE"
      }
    }
  ]
}

/* 
 * VPC Flow Logs Parameter
 */
locals {
  flow_logs = {
    cloudwatch_logs = {
      create               = false
      iam_role_arn         = aws_iam_role.flow_log.arn
      log_destination_type = "cloud-watch-logs"
      log_destination      = aws_cloudwatch_log_group.flow_log.arn
      traffic_type         = "ACCEPT"
      // デフォルトのログフォーマット
      log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"

      max_aggregation_interval = 600
    }
    s3 = {
      create                   = false
      log_destination_type     = "s3"
      log_destination          = aws_s3_bucket.flow_log.arn
      traffic_type             = "ACCEPT"
      log_format               = "$${account-id} $${region} $${interface-id} $${srcaddr} $${dstaddr} $${pkt-srcaddr} $${pkt-dstaddr} $${protocol} $${action} $${log-status}"
      max_aggregation_interval = 60
    }
    # kinesis_data_firehose = {
    #   create                   = false
    #   log_destination_type     = "kinesis-data-firehose"
    #   log_destination          = aws_kinesis_firehose_delivery_stream.logs["common_vpc_flow_logs"].arn
    #   traffic_type             = "ALL"
    #   log_format               = "$${account-id} $${region} $${interface-id} $${srcaddr} $${dstaddr} $${pkt-srcaddr} $${pkt-dstaddr} $${protocol} $${action} $${log-status}"
    #   max_aggregation_interval = 60 // 1分単位でレコードがフローログに集約される。
    #   iam_role_arn         = aws_iam_role.flow_log.arn
    # }
  }
}

locals {
  environment = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
}
