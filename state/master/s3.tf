#####################################################
# S3
#####################################################
/* 
 * tfstate
 */
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_bucket_tfstate" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.11.0"

  # aws_s3_bucket
  bucket              = "tfstate-${data.aws_caller_identity.self.account_id}"
  force_destroy       = false // オブジェクトが入っていても強制的に削除可能
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
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          AWS : [
            "arn:aws:iam::${data.aws_caller_identity.self.account_id}:root",
            "arn:aws:iam::${data.terraform_remote_state.development_state.outputs.account_id}:root"
          ]
        },
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutBucketAcl",
          "s3:PutBucketPolicy",
          "s3:PutObject",
        ],
        "Resource" : [
          module.s3_bucket_tfstate.s3_bucket_arn,
          "${module.s3_bucket_tfstate.s3_bucket_arn}/*"
        ]
        "Condition" : {
          "StringEquals" : {
            "aws:PrincipalOrgID" : data.terraform_remote_state.master_account_management.outputs.org_id
          }
        }
      }
    ]
  })
}
