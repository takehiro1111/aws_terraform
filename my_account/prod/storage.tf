#####################################################
# S3
#####################################################
/* 
 * tfstate
 */
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "tfstate" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.1"

  # aws_s3_bucket
  bucket              = "tfstate-${data.aws_caller_identity.self.account_id}"
  force_destroy       = false // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_ownership_controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

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
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  # aws_s3_bucket_policy
  attach_policy = true
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutBucketAcl",
          "s3:PutObject"
        ],
        "Resource" : [
          module.tfstate.s3_bucket_arn,
          "${module.tfstate.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_object" "tfstate" {
  bucket                 = module.tfstate.s3_bucket_id
  key                    = "prod/state_prod"
  server_side_encryption = "AES256"
  acl                    = "private"
  storage_class          = "STANDARD"

  lifecycle {
    ignore_changes = [tags_all]
  }
}
