#################################################
# S3
#################################################
# MySQL Dumpファイル連携用S3バケット ------------------------
## refarence: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/3.6.0
module "s3_bastion_tmp" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.11.0"

  # insert the 7 required variables her
  bucket = "for-bastion-${data.aws_caller_identity.self.account_id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  logging = {
    target_bucket = module.s3_accesslog_stg.s3_bucket_id
    target_prefix = ""

    target_object_key_format = {
      partitioned_prefix = {
        partition_date_source = "DeliveryTime"
      }
    }
  }

  versioning = {
    enabled = true
  }

  transition_default_minimum_object_size = "varies_by_storage_class"
  lifecycle_rule = {
    rule = {
      id     = "for-bastion-${data.aws_caller_identity.self.account_id}"
      status = "Enabled"

      abort_incomplete_multipart_upload_days = 1

      expiration = {
        days = 1
      }

      noncurrent_version_expiration = {
        noncurrent_days = 1
      }
    }
  }

  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = false
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}


/* 
 * tfstate
 */
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "tfstate" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.11.0"

  # aws_s3_bucket
  bucket              = "terraform-state-${data.aws_caller_identity.self.account_id}-dst"
  force_destroy       = false
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = module.s3_accesslog_stg.s3_bucket_id
    target_prefix = ""

    target_object_key_format = {
      partitioned_prefix = {
        partition_date_source = "DeliveryTime"
      }
    }
  }

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
        Effect    = "Allow",
        Principal = "*",
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject"
        ],
        Resource = [
          module.tfstate.s3_bucket_arn,
          "${module.tfstate.s3_bucket_arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = "o-jmbkdobwgh"
          }
        }
      }
    ]
  })
}

/*
 * S3バケット向けアクセスログ集積用バケット
 */
module "s3_accesslog_stg" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.11.0"

  bucket = "s3-accesslog-stg-comp-${data.aws_caller_identity.self.account_id}"
  versioning = {
    enabled = true
  }
  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = true
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  attach_access_log_delivery_policy = true
  attach_policy                     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.self.account_id}:root"
        }
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
        ]
        Resource = [
          module.s3_accesslog_stg.s3_bucket_arn,
          "${module.s3_accesslog_stg.s3_bucket_arn}/*",
        ]
      }
    ]
  })
  lifecycle_rule = [
    {
      id     = "Delete-logs-after-5-years"
      status = "Enabled"
      expiration = {
        days = 1825
      }
    },
    {
      id     = "Delete-Old-Versions"
      status = "Enabled"
      expiration = {
        days = 0
      }
      noncurrent_version_expiration = {
        noncurrent_days = 1
      }
    },
  ]
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
}

