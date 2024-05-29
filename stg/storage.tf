#===================================
# ECR
#===================================
resource "aws_ecr_repository" "common" {
  for_each = toset(var.repo_list)

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "common" {
  for_each = toset(var.repo_list)

  repository = each.value
  policy     = file("../policy/ecr_repo_policy.json")

  depends_on = [aws_ecr_repository.common]
}

resource "aws_ecr_lifecycle_policy" "common" {
  for_each = toset(var.repo_list)

  repository = each.value
  policy     = file("../policy/ecr_lifecycle_policy.json")

  depends_on = [aws_ecr_repository.common]
}

#=============================================
# S3 Bucket
#=============================================
#tfsatate-------------------------------------
resource "aws_s3_bucket" "tfstate_sekigaku" {
  bucket = "terraform-state-hashicorp"
}

resource "aws_s3_bucket_ownership_controls" "tfstate_sekigaku" {
  bucket = aws_s3_bucket.tfstate_sekigaku.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tfstate_sekigaku" {
  bucket = aws_s3_bucket.tfstate_sekigaku.id
  acl    = "private"

  depends_on = [aws_s3_bucket.tfstate_sekigaku]
}

resource "aws_s3_bucket_public_access_block" "tfstate_sekigaku" {
  bucket = aws_s3_bucket.tfstate_sekigaku.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tfstate_sekigaku" {
  bucket = aws_s3_bucket.tfstate_sekigaku.id

  versioning_configuration {
    status = "Enabled"
  }
}

#機能的には不要だが、試してみたいためコメントアウトで保存している。(2023/11/18時点)
/* resource "aws_s3_bucket_lifecycle_configuration" "tfstate_sekigaku" {
    bucket = aws_s3_bucket.tfstate_sekigaku.id

    rule {
        id     = "test_rule"
        status = "Enabled"

        filter {
            prefix = "terraform-state-sekigaku-:${data.aws_caller_identity.current.id}/${local.env}"
        }
    }
} */

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_sekigaku" {
  bucket = aws_s3_bucket.tfstate_sekigaku.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_policy" "tfstate_sekigaku" {
  bucket = aws_s3_bucket.tfstate_sekigaku.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "sekigaku-user_Aloow",
        "Effect" : "Allow",
        "Principal" : { "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.id}:root" },
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutBucketAcl",
        ],
        "Resource" : [
          "${aws_s3_bucket.tfstate_sekigaku.arn}",
          "${aws_s3_bucket.tfstate_sekigaku.arn}/*",
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_logging" "tfstate_sekigaku" {
  bucket        = aws_s3_bucket.tfstate_sekigaku.id
  target_bucket = aws_s3_bucket.logging-sekigaku-20231120.id
  target_prefix = "${aws_s3_bucket.tfstate_sekigaku.id}/log/"
}

#logging------------------------------------------------------
resource "aws_s3_bucket" "logging-sekigaku-20231120" {
  bucket = "logging-sekigaku-20231120"
}

resource "aws_s3_bucket_ownership_controls" "logging" {
  bucket = aws_s3_bucket.logging-sekigaku-20231120.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logging" {
  bucket = aws_s3_bucket.logging-sekigaku-20231120.id
  acl    = "private"

  depends_on = [aws_s3_bucket.logging-sekigaku-20231120]
}

resource "aws_s3_bucket_public_access_block" "logging" {
  bucket = aws_s3_bucket.logging-sekigaku-20231120.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logging" {
  bucket = aws_s3_bucket.logging-sekigaku-20231120.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  bucket = aws_s3_bucket.logging-sekigaku-20231120.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_policy" "logging-sekigaku-20231120" {
  bucket = aws_s3_bucket.logging-sekigaku-20231120.bucket
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "sekigaku-user_Aloow",
        "Effect" : "Allow",
        "Principal" : { "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.id}:root" },
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutBucketAcl",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.logging-sekigaku-20231120.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.logging-sekigaku-20231120.bucket}/*"
        ]
      },
      {
        "Sid" : "CloudFront_logging_Allow",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "delivery.logs.amazonaws.com",
            "elasticloadbalancing.amazonaws.com"
          ]
        },
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutBucketAcl",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.logging-sekigaku-20231120.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.logging-sekigaku-20231120.bucket}/*"
        ]
      },
      {
        "Sid" : "S3PolicyStmt-DO-NOT-MODIFY-1652337892133",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logging.s3.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.logging-sekigaku-20231120.arn}/*"
      }
    ]
  })
}


#cdn-log----------------------------
resource "aws_s3_bucket" "cdn_log" {
  bucket   = "cdn-log-hashicorp-20231203"
  provider = aws.us-east-1
}

resource "aws_s3_bucket_ownership_controls" "cdn_log" {
  bucket   = aws_s3_bucket.cdn_log.bucket
  provider = aws.us-east-1
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cdn_log" {
  bucket   = aws_s3_bucket.cdn_log.bucket
  provider = aws.us-east-1
  acl      = "private"

  depends_on = [aws_s3_bucket.cdn_log]
}

resource "aws_s3_bucket_public_access_block" "cdn_log" {
  bucket   = aws_s3_bucket.cdn_log.bucket
  provider = aws.us-east-1

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "cdn_log" {
  bucket   = aws_s3_bucket.cdn_log.bucket
  provider = aws.us-east-1

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cdn_log" {
  bucket   = aws_s3_bucket.cdn_log.bucket
  provider = aws.us-east-1

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_logging" "cdn_log" {
  bucket        = aws_s3_bucket.cdn_log.bucket
  target_bucket = aws_s3_bucket.cdn_log.bucket
  target_prefix = "${aws_s3_bucket.cdn_log.bucket}/log/"
  provider      = aws.us-east-1
}

resource "aws_s3_bucket_policy" "cdn_log" {
  bucket   = aws_s3_bucket.cdn_log.bucket
  provider = aws.us-east-1
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "sekigaku-user_Aloow",
        "Effect" : "Allow",
        "Principal" : { "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.id}:root" },
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutBucketAcl",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.cdn_log.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.cdn_log.bucket}/*"
        ]
      },
      {
        "Sid" : "CloudFront_logging_Allow",
        "Effect" : "Allow",
        "Principal" : { "Service" : "cloudfront.amazonaws.com" },
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutBucketAcl",
          "s3:PutObject"
        ]
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.cdn_log.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.cdn_log.bucket}/*"
        ]
      }
    ]
  })
}


# Static -----------------------------
resource "aws_s3_bucket" "test" {
  bucket = "test-static-s3-20231130"
}

resource "aws_s3_object" "test" {
  bucket = aws_s3_bucket.test.id
  #S3へアップロードするときのkey値
  key = "static/sitemap/"
  acl = "private"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.test.bucket
  key    = "error/"
  acl    = "private"
}

resource "aws_s3_object" "maintenance" {
  bucket = aws_s3_bucket.test.bucket
  key    = "maintenance/"
  acl    = "private"
}

resource "aws_s3_object" "image" {
  bucket = aws_s3_bucket.test.bucket
  key    = "image/"
  acl    = "private"
}

resource "aws_s3_object" "bug" {
  bucket                 = aws_s3_bucket.test.bucket
  key                    = "static/maintenance/"
  acl                    = "private"
  server_side_encryption = "aws:kms"
  kms_key_id             = aws_kms_key.s3.arn
}

resource "aws_s3_bucket_ownership_controls" "test" {
  bucket = aws_s3_bucket.test.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "test" {
  bucket = aws_s3_bucket.test.bucket
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.test,
    aws_s3_bucket_public_access_block.test
  ]
}

resource "aws_s3_bucket_versioning" "test" {
  bucket = aws_s3_bucket.test.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "test" {
  bucket                  = aws_s3_bucket.test.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test" {
  bucket = aws_s3_bucket.test.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "test" {
  bucket        = aws_s3_bucket.test.bucket
  target_bucket = aws_s3_bucket.logging-sekigaku-20231120.bucket
  target_prefix = "${local.env}/${local.repository}"
}

#ポリシーを確認
resource "aws_s3_bucket_policy" "test" {
  bucket = aws_s3_bucket.test.id
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Sid" : "sekigaku-user_Aloow",
        "Effect" : "Allow",
        "Principal" : { "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.id}:root" },
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutBucketAcl",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.test.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.test.bucket}/*",
        ]
      },
      {
        "Sid" : "Allow Stg StaticSite",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com",
        }
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.test.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.test.bucket}/*",
        ],
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : module.main_stg.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}

# vpc-flow-log -----------------------------
#::memo::
# #フローログのバケットポリシーはデフォルトで動的に作成されるため、ユーザー側での作成は不要。
resource "aws_s3_bucket" "flow_log" {
  bucket = "vpc-flow-log-put-bucket"
}

resource "aws_s3_bucket_ownership_controls" "flow_log" {
  bucket = aws_s3_bucket.flow_log.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "flow_log" {
  bucket = aws_s3_bucket.flow_log.bucket
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.flow_log,
    aws_s3_bucket_public_access_block.flow_log
  ]
}

resource "aws_s3_bucket_versioning" "flow_log" {
  bucket = aws_s3_bucket.flow_log.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "flow_log" {
  bucket                  = aws_s3_bucket.flow_log.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_log" {
  bucket = aws_s3_bucket.flow_log.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "flow_log" {
  bucket        = aws_s3_bucket.flow_log.bucket
  target_bucket = aws_s3_bucket.logging-sekigaku-20231120.bucket
  target_prefix = "${local.env}/${local.repository}"
}

# Athena -----------------------------------------------
resource "aws_s3_bucket" "athena" {
  bucket = "athena-result-20240407"
}

resource "aws_s3_bucket_ownership_controls" "athena" {
  bucket = aws_s3_bucket.athena.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "athena" {
  bucket = aws_s3_bucket.athena.bucket
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.athena,
    aws_s3_bucket_public_access_block.athena
  ]
}

resource "aws_s3_bucket_versioning" "athena" {
  bucket = aws_s3_bucket.athena.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "athena" {
  bucket                  = aws_s3_bucket.athena.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena" {
  bucket = aws_s3_bucket.athena.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_logging" "athena" {
  bucket        = aws_s3_bucket.athena.bucket
  target_bucket = aws_s3_bucket.logging-sekigaku-20231120.bucket
  target_prefix = "${local.env}/${local.repository}"
}

# config log --------------------------------------------------
module "config_log" {
  source = "../modules/s3/config"

  s3_bucket = "config-${data.aws_caller_identity.current.account_id}"
}
