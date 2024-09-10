#####################################################
# ECR
#####################################################
# KMSでの暗号化は行わない。
#trivy:ignore:AVD-AWS-0033
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

#####################################################
# S3
#####################################################
#tfsatate-------------------------------------
resource "aws_s3_bucket" "tfstate" {
  bucket = "terraform-state-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_ownership_controls" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  acl    = "private"

  depends_on = [aws_s3_bucket.tfstate]
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # "aws:kms"
      #kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_policy" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
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
          aws_s3_bucket.tfstate.arn,
          "${aws_s3_bucket.tfstate.arn}/*",
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_logging" "tfstate" {
  bucket        = aws_s3_bucket.tfstate.id
  target_bucket = aws_s3_bucket.logging.id
  target_prefix = "${aws_s3_bucket.tfstate.id}/log/"
}

#logging------------------------------------------------------
resource "aws_s3_bucket" "logging" {
  bucket = "logging-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_ownership_controls" "logging" {
  bucket = aws_s3_bucket.logging.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logging" {
  bucket = aws_s3_bucket.logging.id
  acl    = "private"

  depends_on = [aws_s3_bucket.logging]
}

resource "aws_s3_bucket_public_access_block" "logging" {
  bucket = aws_s3_bucket.logging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logging" {
  bucket = aws_s3_bucket.logging.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  bucket = aws_s3_bucket.logging.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_policy" "logging" {
  bucket = aws_s3_bucket.logging.bucket
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
          "arn:aws:s3:::${aws_s3_bucket.logging.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.logging.bucket}/*"
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
          "arn:aws:s3:::${aws_s3_bucket.logging.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.logging.bucket}/*"
        ]
      },
      {
        "Sid" : "S3PolicyStmt-DO-NOT-MODIFY-1652337892133",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logging.s3.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.logging.arn}/*"
      }
    ]
  })
}

/* 
 * CloudFront用のアクセスログ
 */
resource "aws_s3_bucket" "cdn_log" {
  bucket   = "cdn-log-${data.aws_caller_identity.current.account_id}"
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
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_logging" "cdn_log" {
  bucket        = aws_s3_bucket.cdn_log.bucket
  target_bucket = aws_s3_bucket.cdn_log.bucket
  target_prefix = "${aws_s3_bucket.cdn_log.bucket}/cdn_log/"
  provider      = aws.us-east-1
}

resource "aws_s3_bucket_lifecycle_configuration" "cdn_log" {
  bucket   = aws_s3_bucket.cdn_log.id
  provider = aws.us-east-1

  dynamic "rule" {
    for_each = local.lifecycle_configuration

    content {
      id     = rule.value.id
      status = rule.value.status

      filter {
        prefix = rule.value.prefix
      }

      dynamic "transition" {
        for_each = rule.value.transitions

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      noncurrent_version_transition {
        newer_noncurrent_versions = rule.value.noncurrent_version_transition.newer_noncurrent_versions
        noncurrent_days           = rule.value.noncurrent_version_transition.noncurrent_days
        storage_class             = rule.value.noncurrent_version_transition.storage_class
      }
    }
  }
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
        "Condition" : {
          "StringLike" : {
            "AWS:SourceArn" : "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/*"
          }
        }
      }
    ]
  })
}


# Static -----------------------------
resource "aws_s3_bucket" "static" {
  bucket = "static-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_ownership_controls" "static" {
  bucket = aws_s3_bucket.static.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "static" {
  bucket = aws_s3_bucket.static.bucket
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.static,
    aws_s3_bucket_public_access_block.static
  ]
}

resource "aws_s3_bucket_versioning" "static" {
  bucket = aws_s3_bucket.static.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "static" {
  bucket                  = aws_s3_bucket.static.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static" {
  bucket = aws_s3_bucket.static.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "static" {
  bucket        = aws_s3_bucket.static.bucket
  target_bucket = aws_s3_bucket.logging.bucket
  target_prefix = "${local.env}/${local.repository}"
}

#ポリシーを確認
resource "aws_s3_bucket_policy" "static" {
  bucket = aws_s3_bucket.static.id
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
          "arn:aws:s3:::${aws_s3_bucket.static.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.static.bucket}/*",
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
          "arn:aws:s3:::${aws_s3_bucket.static.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.static.bucket}/*",
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
  bucket = "vpc-flow-log-${data.aws_caller_identity.current.account_id}"
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
  target_bucket = aws_s3_bucket.logging.bucket
  target_prefix = "${local.env}/${local.repository}"
}

/* 
 * Athena
 */
resource "aws_s3_bucket" "athena" {
  bucket = "athena-${data.aws_caller_identity.current.account_id}"
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
  target_bucket = aws_s3_bucket.logging.bucket
  target_prefix = "${local.env}/${local.repository}"
}

# config log --------------------------------------------------
module "config_log" {
  source = "../modules/s3/config"

  bucket_name    = "config-${data.aws_caller_identity.current.account_id}"
  bucket_logging = aws_s3_bucket.logging.bucket
}

# ALB Access Log ----------------------------------------------
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_alb_accesslog" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  # aws_s3_bucket
  bucket              = "alb-accesslog-${data.aws_caller_identity.current.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = aws_s3_bucket.logging.bucket
    target_prefix = "alb_access_log"

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
    Version = "2012-10-17"
    Id      = "For ALB Access Logging"
    Statement = [
      {
        Sid    = "For ALB Access Logging"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            "arn:aws:iam::582318560864:root" // 東京リージョンにおけるALBのログ配信を管理するために使用される内部的なAWSアカウント
          ]
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${module.s3_alb_accesslog.s3_bucket_arn}/common/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        ]
      },
    ]
  })


  # aws_s3_bucket_lifecycle_configuration
}


#####################################################################
# S3 Inventory Verification
#####################################################################
/* 
 * Athena
 */
# resource "aws_s3_bucket_inventory" "athena" {
#   bucket = aws_s3_bucket.athena.id
#   name   = "AthenaBucket-Inventory"
#   included_object_versions = "Current" // 現在のバージョンのみを対象。
#   schedule {
#     frequency = "Daily" // 日次でのレポート送信
#   }
#   destination {
#     bucket {
#       format     = "CSV"
#       bucket_arn = module.s3_inventory_dist.s3_bucket_arn // インベントリレポートの送信先バケットを指定
#       prefix     = "athena"
#       // インベントリで出力されるレポートファイルの暗号化設定
#       encryption {
#         sse_s3 {}
#       }
#     }
#   }
# }

# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_inventory_dist" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  # aws_s3_bucket
  bucket              = "s3-inventory-dist-${data.aws_caller_identity.current.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = aws_s3_bucket.logging.bucket
    target_prefix = "s3_inventory_dist"

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
    Id      = "s3iinventory-permission",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = [
          module.s3_inventory_dist.s3_bucket_arn,
          "${module.s3_inventory_dist.s3_bucket_arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id,
            "s3:x-amz-acl"      = "bucket-owner-full-control"
          },
          ArnLike = {
            "aws:SourceArn" = [
              // インベントリレポートの送信元バケットを記載。
              aws_s3_bucket.athena.arn
            ]
          }
        }
      }
    ]
  })
}

# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_batch_operation_dist" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  # aws_s3_bucket
  bucket              = "s3-batch-operation-dist-${data.aws_caller_identity.current.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = aws_s3_bucket.logging.bucket
    target_prefix = "s3_batch_operation_dist"

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
    Id      = "s3-batchoperation-permission",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "batchoperations.s3.amazonaws.com"
        },
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectAcl"
        ]
        Resource = [
          module.s3_batch_operation_dist.s3_bucket_arn,
          "${module.s3_batch_operation_dist.s3_bucket_arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          },
          ArnLike = {
            "aws:SourceArn" = [
              "arn:aws:s3::${data.aws_caller_identity.current.account_id}:job/*"
            ]
          }
        }
      }
    ]
  })
}

# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_batch_operation_report_dist" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  # aws_s3_bucket
  bucket              = "s3-batch-operation-report-dist-${data.aws_caller_identity.current.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = aws_s3_bucket.logging.bucket
    target_prefix = "s3_batch_operation_report_dist"

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
    Id      = "s3 batch operation report permission",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "batchoperations.s3.amazonaws.com"
        },
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectAcl"
        ]
        Resource = [
          module.s3_batch_operation_report_dist.s3_bucket_arn,
          "${module.s3_batch_operation_report_dist.s3_bucket_arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          },
          ArnLike = {
            "aws:SourceArn" = [
              "arn:aws:s3::${data.aws_caller_identity.current.account_id}:job/*"
            ]
          }
        }
      }
    ]
  })
}

########################################################################
# Export logs from CloudwatchLogs to S3
########################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "cloudwatchlogs_to_s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  # aws_s3_bucket
  bucket              = "cloudwatchlogs-to-s3-${data.aws_caller_identity.current.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = aws_s3_bucket.logging.bucket
    target_prefix = "cloudwatchlogs_to_s3"

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
  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "logs.${data.aws_region.default.name}.amazonaws.com"
        },
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject",
        ]
        Resource = [
          module.cloudwatchlogs_to_s3.s3_bucket_arn,
          "${module.cloudwatchlogs_to_s3.s3_bucket_arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = [
              "arn:aws:logs:${data.aws_region.default.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
            ]
          }
        }
      }
    ]
  })

  # aws_s3_bucket_lifecycle_configuration
  lifecycle_rule = [
    {
      id     = "log"
      status = "Enabled"

      transition = {
        days          = 90
        storage_class = "STANDARD_IA"
      }

      transition = {
        days          = 180
        storage_class = "GLACIER"
      }

      transition = {
        days          = 365
        storage_class = "DEEP_ARCHIVE"
      }
    },
    {
      id     = "delete_old_objects"
      status = "Enabled"

      expiration = {
        days = 1825 // 5年
      }
    }
  ]
}

/* 
 * us-east-1
 */
// 公式Moduleだとデフォルトリージョンでしか作成できないためresourceブロックで作成。
// aws_s3_bucket_loggingについては、クロスリージョンのロギングが出来ないため未設定。
resource "aws_s3_bucket" "cloudwatchlogs_to_s3_us_east_1" {
  bucket   = "cloudwatchlogs-to-s3-${data.aws_caller_identity.current.account_id}-us-east-1"
  provider = aws.us-east-1
}

resource "aws_s3_bucket_ownership_controls" "cloudwatchlogs_to_s3_us_east_1" {
  bucket   = aws_s3_bucket.cloudwatchlogs_to_s3_us_east_1.bucket
  provider = aws.us-east-1
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudwatchlogs_to_s3_us_east_1" {
  depends_on = [aws_s3_bucket.cloudwatchlogs_to_s3_us_east_1]
  bucket     = aws_s3_bucket.cloudwatchlogs_to_s3_us_east_1.bucket
  provider   = aws.us-east-1
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "cloudwatchlogs_to_s3_us_east_1" {
  bucket   = aws_s3_bucket.cloudwatchlogs_to_s3_us_east_1.bucket
  provider = aws.us-east-1
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudwatchlogs_to_s3_us_east_1" {
  bucket                  = aws_s3_bucket.cloudwatchlogs_to_s3_us_east_1.bucket
  provider                = aws.us-east-1
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudwatchlogs_to_s3_us_east_1" {
  bucket   = aws_s3_bucket.cloudwatchlogs_to_s3_us_east_1.bucket
  provider = aws.us-east-1
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudwatchlogs_to_s3_us_east_1" {
  bucket   = aws_s3_bucket.cloudwatchlogs_to_s3_us_east_1.bucket
  provider = aws.us-east-1
  rule {
    id     = "log"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }
  }

  rule {
    id     = "delete_old_objects"
    status = "Enabled"

    expiration {
      days = 1825 // 5years
    }
  }
}

resource "aws_s3_bucket_policy" "cloudwatchlogs_to_s3_us_east_1" {
  bucket   = aws_s3_bucket.cloudwatchlogs_to_s3_us_east_1.bucket
  provider = aws.us-east-1
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "logs.us-east-1.amazonaws.com"
        },
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject",
        ]
        Resource = [
          aws_s3_bucket.cloudwatchlogs_to_s3_us_east_1.arn,
          "${aws_s3_bucket.cloudwatchlogs_to_s3_us_east_1.arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = [
              "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:*"
            ]
          }
        }
      }
    ]
  })
}

########################################################################
# Common commands used in SAM CLI
########################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "sam_deploy" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  # aws_s3_bucket
  bucket              = "sam-deploy-${data.aws_caller_identity.current.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = aws_s3_bucket.logging.bucket
    target_prefix = "sam_deploy"

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
  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.id}:root"
        },
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          module.sam_deploy.s3_bucket_arn,
          "${module.sam_deploy.s3_bucket_arn}/*",
        ]
        # Condition = {
        #   StringEquals = {
        #     "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        #   }
        # }
      }
    ]
  })

  # aws_s3_bucket_lifecycle_configuration
  lifecycle_rule = [
    {
      id     = "log"
      status = "Enabled"

      transition = {
        days          = 90
        storage_class = "STANDARD_IA"
      }

      transition = {
        days          = 180
        storage_class = "GLACIER"
      }

      transition = {
        days          = 365
        storage_class = "DEEP_ARCHIVE"
      }
    },
    {
      id     = "delete_old_objects"
      status = "Enabled"

      expiration = {
        days = 1825 // 5年
      }
    }
  ]
}

########################################################################
# Firehose Delivery Logs
########################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "firehose_delivery_logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"
  #   providers = {
  #   aws = aws.us-east-1
  # }

  # aws_s3_bucket
  bucket              = "firehose-delivery-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = aws_s3_bucket.logging.bucket
    target_prefix = "firehose-delivery-logs"

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
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.firehose_delivery_role.arn
        },
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          "${module.firehose_delivery_logs.s3_bucket_arn}/*",
        ]
      }
    ]
  })

  # aws_s3_bucket_lifecycle_configuration
  lifecycle_rule = [
    {
      id     = "log"
      status = "Enabled"

      transition = {
        days          = 90
        storage_class = "STANDARD_IA"
      }

      transition = {
        days          = 180
        storage_class = "GLACIER"
      }

      transition = {
        days          = 365
        storage_class = "DEEP_ARCHIVE"
      }
    },
    {
      id     = "delete_old_objects"
      status = "Enabled"

      expiration = {
        days = 1825 // 5年
      }
    }
  ]
}
