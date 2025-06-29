##################################################################################
# AuditLog for AWS CloudTrail
##################################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_bucket_cloudtrail_audit_log" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.11.0"
  create_bucket = true

  # aws_s3_bucket
  bucket              = "aws-cloudtrail-${data.terraform_remote_state.master_account_management.outputs.org_id}-${data.aws_region.default.name}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_ownership_controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  # aws_s3_bucket_acl
  acl = "private"

  # aws_s3_bucket_versioning
  versioning = {
    enabled = true
  }

  # aws_s3_bucket_server_side_encryption_configuration
  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = false
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # aws_s3_bucket_public_access_block
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # aws_s3_bucket_policy
  attach_policy = true
  policy        = data.aws_iam_policy_document.cloudtrail_audit_log.json

  # aws_s3_bucket_lifecycle_configuration
  lifecycle_rule = [
    {
      id     = "delete_old_objects"
      status = "Enabled"
      expiration = {
        days = 1
      }
    },
    {
      id     = "delete_old_versions"
      status = "Enabled"
      expiration = {
        expired_object_delete_marker = true
      }
    }
  ]
}

// reference: https://docs.aws.amazon.com/ja_jp/awscloudtrail/latest/userguide/cloudtrail-create-and-update-an-organizational-trail-by-using-the-aws-cli.html
data "aws_iam_policy_document" "cloudtrail_audit_log" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [module.s3_bucket_cloudtrail_audit_log.s3_bucket_arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [data.terraform_remote_state.master_account_management.outputs.cloudtrail_arn]
    }
  }
  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${module.s3_bucket_cloudtrail_audit_log.s3_bucket_arn}/AWSLogs/${data.aws_caller_identity.self.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [data.terraform_remote_state.master_account_management.outputs.cloudtrail_arn]
    }
  }
  statement {
    sid    = "AWSCloudTrailOrganizationWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.${data.aws_partition.current.dns_suffix}"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${module.s3_bucket_cloudtrail_audit_log.s3_bucket_arn}/AWSLogs/${data.terraform_remote_state.master_account_management.outputs.org_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [data.terraform_remote_state.master_account_management.outputs.cloudtrail_arn]
    }
  }
}

##################################################################################
# AuditLog for AWS Config
##################################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_bucket_config_audit_log" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.11.0"
  create_bucket = true

  # aws_s3_bucket
  bucket              = "aws-config-${data.terraform_remote_state.master_account_management.outputs.org_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_ownership_controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  # aws_s3_bucket_acl
  acl = "private"

  # aws_s3_bucket_versioning
  versioning = {
    enabled = true
  }

  # aws_s3_bucket_server_side_encryption_configuration
  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = false
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # aws_s3_bucket_public_access_block
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # aws_s3_bucket_policy
  attach_policy = true
  policy        = data.aws_iam_policy_document.this.json

  # aws_s3_bucket_lifecycle_configuration
  lifecycle_rule = [
    {
      id     = "delete_old_objects"
      status = "Enabled"
      expiration = {
        days = 1
      }
    },
    {
      id     = "delete_old_versions"
      status = "Enabled"
      expiration = {
        expired_object_delete_marker = true
      }
    }
  ]
}

// reference: https://docs.aws.amazon.com/ja_jp/config/latest/developerguide/s3-bucket-policy.html
data "aws_iam_policy_document" "this" {
  version = "2012-10-17"
  statement {
    sid    = "AWSConfigBucketPermissionsCheck & AWSConfigBucketExistenceCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.${data.aws_partition.current.dns_suffix}"]
    }
    actions   = ["s3:GetBucketAcl", "s3:ListBucket"]
    resources = [module.s3_bucket_config_audit_log.s3_bucket_arn]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values = [
        data.aws_caller_identity.self.account_id,
        data.terraform_remote_state.development_storage.outputs.account_id
      ]
    }
  }
  statement {
    sid     = "AWSConfigBucketDelivery"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    principals {
      type        = "Service"
      identifiers = ["config.${data.aws_partition.current.dns_suffix}"]
    }
    resources = ["${module.s3_bucket_config_audit_log.s3_bucket_arn}/AWSLogs/*/Config/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values = [
        data.aws_caller_identity.self.account_id,
        data.terraform_remote_state.development_storage.outputs.account_id
      ]
    }
  }
}

########################################################################
# SAM Templates
########################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_bucket_sam_deploy" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.11.0"
  create_bucket = true

  # aws_s3_bucket
  bucket              = "sam-deploy-${data.aws_caller_identity.self.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_ownership_controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  # aws_s3_bucket_acl
  acl = "private"

  # aws_s3_bucket_versioning
  versioning = {
    enabled = true
  }

  # aws_s3_bucket_server_side_encryption_configuration
  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = false
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # aws_s3_bucket_public_access_block
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # aws_s3_bucket_policy
  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.self.id}:root"
        },
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          module.s3_bucket_sam_deploy.s3_bucket_arn,
          "${module.s3_bucket_sam_deploy.s3_bucket_arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.self.account_id
          }
        }
      }
    ]
  })

  # aws_s3_bucket_lifecycle_configuration
  lifecycle_rule = [
    {
      id     = "delete_old_objects"
      status = "Enabled"
      expiration = {
        days = 3
      }
    },
    {
      id     = "delete_old_versions"
      status = "Enabled"
      expiration = {
        expired_object_delete_marker = true
      }
    }
  ]
}
