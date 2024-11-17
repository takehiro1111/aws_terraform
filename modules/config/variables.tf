variable "create" {
  description = "Configの設定の作成可否を制御"
  type        = bool
  default     = true
}

variable "name" {
  type = string
}

variable "recorder_role_arn" {
  description = "AWS Configに付与するIAMロール"
  type        = string
  default     = "AWSServiceRoleForConfig"
}

variable "use_exclude_specific_resource_types" {
  description = "特定のリソースタイプのみを記録する場合はtrue"
  type        = bool
  default     = false
}

variable "all_supported" {
  description = "全てのリソースタイプを記録する場合はtrue"
  type        = bool
  default     = true
}

variable "include_global_resource_types" {
  description = "リージョンに依存しないリソースタイプを記録する場合はtrue"
  type        = bool
  default     = true
}

variable "configuration_recorder_exclusion_by_resource_types" {
  description = "特定のリソースタイプを記録対象から除外するための設定"
  type        = list(string)
  default     = []
}

variable "recording_frequency" {
  description = "Configを記録する頻度"
  type        = string
  default     = "DAILY"
}

variable "configuration_recorder_configuration_recorder_recording_strategy" {
  description = "ALL_SUPPORTED_RESOURCE_TYPESを除く場合のrecording_strategyの値"
  type        = string
  default     = "EXCLUSION_BY_RESOURCE_TYPES"
}

variable "recording_mode_overrides" {
  type = map(object({
    description         = string
    resource_types      = list(string)
    recording_frequency = string
  }))
  default = {}
}

variable "s3_bucket_name" {
  description = "Configで収集した履歴を保管するバケット"
  type        = string
}


variable "config_rules" {
  description = "Map of Config rules to be created"
  type = map(object({
    source_identifier           = string
    compliance_resource_types   = list(string)
    input_parameters            = optional(map(string))
    maximum_execution_frequency = optional(string)
  }))
}
