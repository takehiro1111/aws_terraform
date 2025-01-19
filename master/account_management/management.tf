###############################################################################
# AWS CloudTrail
##############################################################################
module "aws_cloudtrail_ap_northeast_1" {
  source = "../../modules/cloudtrail"
  create = true

  name                          = "${replace(local.service_name, "_", "-")}-${data.aws_ssm_parameter.org_id.value}"
  s3_bucket_name                = data.terraform_remote_state.master_storage.outputs.s3_bucket_id_cloudtrail_audit_log
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  enable_log_file_validation    = true
  is_organization_trail         = true

  insight_selectors = {
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

###############################################################################
# AWS  Config
##############################################################################
module "aws_config_organizations" {
  source                     = "../../modules/config"
  create                     = false // コストかかるため、falseにしておく。
  recorder_status_is_enabled = false

  name                = "${replace(local.service_name, "_", "-")}-${data.aws_caller_identity.self.account_id}"
  recording_frequency = "DAILY"
  s3_bucket_name      = data.terraform_remote_state.master_storage.outputs.s3_bucket_id_config_audit_log

  use_exclude_specific_resource_types = true
  configuration_recorder_exclusion_by_resource_types = [
    "AWS::EC2::NetworkInterface"
  ]

  config_rules = {
    s3_bucket_versioning_enabled = {
      source_identifier         = "S3_BUCKET_VERSIONING_ENABLED"
      compliance_resource_types = ["AWS::S3::Bucket"]
    }
  }
}

#trivy:ignore:AVD-AWS-0019  // (HIGH): Configuration aggregation is not set to source from all regions.
resource "aws_config_configuration_aggregator" "aws_config_organizations" {
  name = "${replace(local.service_name, "_", "-")}-${data.aws_caller_identity.self.account_id}"

  organization_aggregation_source {
    regions  = [data.aws_region.default.name, data.aws_region.us_east_1.name]
    role_arn = aws_iam_role.config_configuration_aggregator.arn
  }
}

###############################################################################
# IAM ROle for AWS Config
###############################################################################
/* 
 * aws_config_configuration_aggregator
 */
resource "aws_iam_role" "config_configuration_aggregator" {
  name               = "config-configuration-aggregator"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.config_configuration_aggregator.json
}

data "aws_iam_policy_document" "config_configuration_aggregator" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "config_configuration_aggregator" {
  role       = aws_iam_role.config_configuration_aggregator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}



locals {
  name = toset(["test1-10"])
}

resource "aws_iam_user" "test" {
  for_each = local.name
  name     = each.key
}

###############################################################################
# SSM Parameter Store
###############################################################################
locals {
  ap_northeast_1 = {
    family_name = {
      name        = "/name/FamilyName"
      description = "苗字"
      type        = "String"
    }
    given_name = {
      name        = "/name/GiveNname"
      description = "名前"
      type        = "String"
    }
    org_id = {
      name        = "/id/organizations"
      description = "ユーザーネーム"
      type        = "SecureString"
    }
  }
}

resource "aws_ssm_parameter" "ap_northeast_1" {
  for_each    = { for k, v in local.ap_northeast_1 : k => v }
  name        = each.value.name
  description = each.value.description
  type        = each.value.type
  value       = "コンソール画面で設定する。"

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "family_name" {
  name = local.ap_northeast_1.family_name.name
}

data "aws_ssm_parameter" "given_name" {
  name = local.ap_northeast_1.given_name.name
}

data "aws_ssm_parameter" "org_id" {
  name = local.ap_northeast_1.org_id.name
}
