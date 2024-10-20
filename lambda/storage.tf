#####################################################
# S3
#####################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "lambda_event" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.1"

  # aws_s3_bucket
  bucket              = "lambda-event-${data.aws_caller_identity.current.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = data.terraform_remote_state.common.outputs.s3_logging_bucket
    target_prefix = "lambda_event"

    target_object_key_format = {
      partitioned_prefix = {
        partition_date_source = "EventTime"
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
  # ref: https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/enable-access-logging.html
  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.id}:root"
        },
        Action   = [ 
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectAcl"
        ]
        Resource = [
          module.lambda_event.s3_bucket_arn,
          "${module.lambda_event.s3_bucket_arn}/*",
        ]
      }
    ]
  })
}
