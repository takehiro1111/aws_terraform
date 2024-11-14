###############################################################################
# AWS  Config
##############################################################################
module "aws_config_organizations" {
  source = "../../modules/config"

  name                = "${replace(local.service_name, "_", "-")}-${data.aws_caller_identity.self.account_id}"
  recorder_role_arn        = data.aws_iam_role.config_configuration_recorder.arn
  recording_frequency = "DAILY"
  s3_bucket_name      = data.terraform_remote_state.master_storage.outputs.s3_bucket_id_config_audit_log
  regions = ["ap-northeast-1","us-east-1"]
  aggregator_role_arn = aws_iam_role.config_configuration_aggregator.arn

  config_rules = {
    s3_bucket_versioning_enabled = {
      source_identifier         = "S3_BUCKET_VERSIONING_ENABLED"
      compliance_resource_types = ["AWS::S3::Bucket"]
    }
  }
}

###############################################################################
# IAM ROle for AWS Config
##############################################################################
/* 
 * aws_config_configuration_recorder
 */
data "aws_iam_role" "config_configuration_recorder" {
  name = "AWSServiceRoleForConfig"
}

/* 
 * aws_config_configuration_aggregator
 */
resource "aws_iam_role" "config_configuration_aggregator" {
  name               = "config-configuration-aggregator"
  path                  = "/service-role/"
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
