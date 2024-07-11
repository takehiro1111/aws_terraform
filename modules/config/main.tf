resource "aws_iam_service_linked_role" "this" {
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder" "this" {
  name     = var.name
  role_arn = aws_iam_service_linked_role.this.arn
  recording_group {
    all_supported                 = "true"
    include_global_resource_types = "true"
  }

  recording_mode {
    recording_frequency = "DAILY"

    dynamic "recording_mode_override" {
      for_each = toset(var.recording_mode_overrides)

      content {
        description         = recording_mode_override.value.description
        resource_types      = recording_mode_override.value.resource_types
        recording_frequency = recording_mode_override.value.recording_frequency
      }
    }
  }
}

resource "aws_config_delivery_channel" "this" {
  name           = var.name
  s3_bucket_name = var.s3_bucket_name
  depends_on     = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_config_rule" "this" {
  for_each = toset(var.config_rules)
  name     = each.key

  source {
    owner             = "AWS"
    source_identifier = each.value.source_identifier
  }

  scope {
    compliance_resource_types = can(each.value.compliance_resource_types) ? each.value.compliance_resource_types : null
  }
  input_parameters = can(each.value.input_parameters) ? each.value.input_parameters : null
  maximum_execution_frequency = can(each.value.maximum_execution_frequency) ? each.value.maximum_execution_frequency : null

  depends_on = [aws_config_configuration_recorder.this]
}
