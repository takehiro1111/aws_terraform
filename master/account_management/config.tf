###############################################################################
# AWS  Config
##############################################################################
module "aws_config_organizations" {
  source = "../../modules/config"
  create = true

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
