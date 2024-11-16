###############################################################################
# AWS  Config
##############################################################################
module "aws_config_organizations" {
  source = "../../modules/config"

  name                = "${replace(local.service_name, "_", "-")}-${data.aws_caller_identity.self.account_id}"
  recorder_role_arn   = aws_iam_service_linked_role.config.arn
  recording_frequency = "DAILY"
  s3_bucket_name      = data.terraform_remote_state.master_storage.outputs.s3_bucket_id_config_audit_log
  regions             = ["ap-northeast-1", "us-east-1"]
  aggregator_role_arn = aws_iam_role.config_configuration_aggregator.arn

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

  config_aggregate_authorization = {
    development_ap_northeast_1 = {
      account_id = data.terraform_remote_state.development_state.outputs.account_id
      region     = data.aws_region.default.name
    }
    development_us_east_1 = {
      account_id = data.terraform_remote_state.development_state.outputs.account_id
      region     = data.aws_region.us_east_1.name
    }
  }
}


###############################################################################
# IAM ROle for AWS Config
##############################################################################
/* 
 * aws_config_configuration_recorder
 */
resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

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
