###############################################################################
# AWS  Config
##############################################################################
module "aws_config_organizations" {
  source = "../../modules/config"

  name                = "${replace(local.service_name, "_", "-")}-${data.aws_region.default.name}"
  iam_role_arn        = aws_iam_role.config.arn
  recording_frequency = "DAILY"
  s3_bucket_name      = data.terraform_remote_state.master_storage.outputs.s3_bucket_id_config_audit_log
  regions = ["ap-northeast-1","us-east-1"]
  aggregator_role_arn = aws_iam_role.config.arn

  config_rules = {
    x3_bucket_versioning_enabled = {
      source_identifier         = "S3_BUCKET_VERSIONING_ENABLED"
      compliance_resource_types = ["AWS::S3::Bucket"]
    }
  }
}


###############################################################################
# IAM ROle for AWS Config
##############################################################################
data "aws_iam_policy" "service_role_policy_config" {
  name = "AWSConfigServiceRolePolicy"
}

resource "aws_iam_role_policy_attachment" "service_role_config" {
  role       = aws_iam_role.config.name
  policy_arn = data.aws_iam_policy.service_role_policy_config.arn
}

resource "aws_iam_role" "config" {
  name               = "awsconfig"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_config.json
}

data "aws_iam_policy_document" "assume_role_policy_config" {
  version = "2012-10-17"
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role_policy" "trust_polic_config" {
  name   = aws_iam_role.config.name
  role   = aws_iam_role.config.name
  policy = data.aws_iam_policy_document.trust_polic_config.json
}


data "aws_iam_policy_document" "trust_polic_config" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject*"
    ]
    resources = [
      "${data.terraform_remote_state.master_storage.outputs.s3_bucket_arn_config_audit_log}/*"
    ]
    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      data.terraform_remote_state.master_storage.outputs.s3_bucket_arn_config_audit_log
    ]
  }
}
