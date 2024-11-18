##################################################################
# Cloud Trail
##################################################################
variable "create" {
  description = "Whether to create the CloudTrail"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the CloudTrail"
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to store the CloudTrail logs"
  type        = string
}

variable "cloud_watch_logs_group_arn" {
  description = "The ARN of the CloudWatch Logs group to which CloudTrail logs will be delivered"
  type        = string
  default     = null
}

variable "include_global_service_events" {
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files"
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Specifies whether the trail is created in the current region or in all regions"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Specifies whether the trail is currently logging AWS API calls"
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Specifies whether log file integrity validation is enabled"
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = "Specifies whether the trail is an AWS Organizations trail"
  type        = bool
  default     = true
}

# variable "enable_insight_selectors" {
#   description = "Specifies whether the trail is publishing events from global services such as IAM to the log files"
#   type        = bool
#   default     = true
# }

variable "insight_selectors" {
  description = "A map of insight selectors"
  type = map(object({
    insight_type = string
    enabled      = bool
  }))
  default = {
    api_call_rate_insight = {
      insight_type = "ApiCallRateInsight"
      enabled      = false
    }
    api_error_rate_insight = {
      insight_type = "ApiErrorRateInsight"
      enabled      = false
    }
  }
}

##################################################################
# CloudWatch Logs
##################################################################
variable "create_cw_log_group" {
  description = "The name of the CloudWatch Logs group"
  type        = bool
  default     = false
}
