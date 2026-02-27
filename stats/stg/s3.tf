########################################################################
# Forwarding VPC Flowlogs
########################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_bucket_forwarding_vpc_flow_logs" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "5.10.0"
  create_bucket = false

  # aws_s3_bucket
  bucket              = "forward-vpc-flow-logs-${data.aws_caller_identity.self.account_id}"
  force_destroy       = true // 一時的な検証用に使用するバケットのため
  object_lock_enabled = true

  # aws_s3_bucket_logging
  logging = {
    target_bucket = module.s3_bucket_logging_target.s3_bucket_id
    target_prefix = replace(trimprefix(module.s3_bucket_vpc_flow_logs.s3_bucket_id, "-${data.aws_caller_identity.self.account_id}"), "-", "_")

    target_object_key_format = {
      partitioned_prefix = {
        partition_date_source = "DeliveryTime"
      }
    }
  }

  # aws_s3_bucket_ownership_controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

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
          Service = "delivery.logs.amazonaws.com"
        },
        Action = [
          "s3:Get*",
          "s3:List*"
        ]
        Resource = module.s3_bucket_vpc_flow_log.s3_bucket_arn
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        },
        Action   = "s3:PutObject"
        Resource = "${module.s3_bucket_vpc_flow_log.s3_bucket_arn}/*"
      }
    ]
  })

  # aws_s3_bucket_lifecycle_configuration
  lifecycle_rule = [
    {
      id     = "delete_old_objects"
      status = "Enabled"

      expiration = {
        days = 30
      }
    }
  ]
}
