variable "name" {
  type = "string"
}

variable "use_exclude_specific_resource_types" {
  description = "特定のリソースタイプのみを記録する場合はtrue"
  type = bool
  default = false
}

variable "all_supported" {
  description = "全てのリソースタイプを記録する場合はtrue"
  type = bool
  default= true
}

variable "include_global_resource_types" {
  description = "リージョンに依存しないリソースタイプを記録する場合はtrue"
  type = bool
  default= true
}

variable "configuration_recorder_exclusion_by_resource_types" {
  description = "特定のリソースタイプを記録対象から除外するための設定"
  type = "string"
  default = null
}

variable "configuration_recorder_configuration_recorder_recording_strategy" {
  description = "ALL_SUPPORTED_RESOURCE_TYPESを除く場合のrecording_strategyの値"
  type = "string"
  default = null
}

variable "recording_mode_overrides" {
  type = list(object({
    description         = string
    resource_types      = list(string)
    recording_frequency = string
  }))
  default = [
    {
      description         = "Only record EC2 network interfaces daily"
      resource_types      = ["AWS::EC2::NetworkInterface"]
      recording_frequency = "DAILY"
    }
  ]
}

variable "s3_bucket_name" {
  description = "Configで収集した履歴を保管するバケット"
  type = "string"
}


variable "config_rules" {
  description = "Map of Config rules to be created"
  type = map(object({
    source_identifier          = string
    compliance_resource_types  = list(string)
    input_parameters           = map(string)
    maximum_execution_frequency = string
  }))
}
