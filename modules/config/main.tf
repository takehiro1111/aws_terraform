###############################################################################
# IAM ROle for AWS Config
###############################################################################
/* 
 * aws_config_configuration_recorder
 */
resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

#########################################################################################
# AWS Config
#########################################################################################
# AWS Configがリソースの設定変更を記録するための設定を定義。
resource "aws_config_configuration_recorder" "this" {
  count    = var.create ? 1 : 0
  name     = var.name
  role_arn = aws_iam_service_linked_role.config.arn

  recording_group {
    all_supported                 = var.use_exclude_specific_resource_types == false ? var.all_supported : false
    include_global_resource_types = var.use_exclude_specific_resource_types == false ? var.include_global_resource_types : false

    dynamic "exclusion_by_resource_types" {
      for_each = length(var.configuration_recorder_exclusion_by_resource_types) > 0 ? var.configuration_recorder_exclusion_by_resource_types : []
      content {
        resource_types = var.configuration_recorder_exclusion_by_resource_types
      }
    }

    dynamic "recording_strategy" {
      for_each = length(var.configuration_recorder_exclusion_by_resource_types) > 0 ? var.configuration_recorder_exclusion_by_resource_types : []
      content {
        use_only = var.use_exclude_specific_resource_types == false ? "ALL_SUPPORTED_RESOURCE_TYPES" : var.configuration_recorder_configuration_recorder_recording_strategy
      }
    }
  }

  recording_mode {
    recording_frequency = var.recording_frequency

    dynamic "recording_mode_override" {
      for_each = { for k, v in var.recording_mode_overrides : k => v }

      content {
        description         = try(recording_mode_override.value.description, null)
        resource_types      = try(recording_mode_override.value.resource_types, [])
        recording_frequency = try(recording_mode_override.value.recording_frequency, null)
      }
    }
  }
}

# AWS Configが設定変更のスナップショットをS3バケットに配信するための設定を定義する
resource "aws_config_delivery_channel" "this" {
  count          = var.create ? 1 : 0
  name           = var.name
  s3_bucket_name = var.s3_bucket_name
  depends_on     = [aws_config_configuration_recorder.this]

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }
}

# AWS Configの設定変更記録のステータスを管理する
resource "aws_config_configuration_recorder_status" "this" {
  count      = var.create ? 1 : 0
  name       = var.name
  is_enabled = var.recorder_status_is_enabled
  depends_on = [aws_config_delivery_channel.this]
}


# AWS Configがリソースの設定を評価するためのルールを定義する
resource "aws_config_config_rule" "this" {
  for_each = {
    for k, v in var.config_rules : k => v
    if var.create
  }
  name = each.key

  source {
    owner             = "AWS"
    source_identifier = each.value.source_identifier
  }

  scope {
    compliance_resource_types = try(each.value.compliance_resource_types, null)
  }

  input_parameters            = each.value.input_parameters != null ? jsonencode(each.value.input_parameters) : null
  maximum_execution_frequency = try(each.value.maximum_execution_frequency, null)

  depends_on = [aws_config_configuration_recorder.this]
}
