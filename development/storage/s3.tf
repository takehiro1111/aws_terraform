################################################################################
# Logging TargetBucket
################################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#trivy:ignore:AVD-AWS-0089 // (LOW): Bucket has logging disabled
module "s3_bucket_logging_target" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = true

  # aws_s3_bucket
  bucket              = "logging-target-${data.aws_caller_identity.self.account_id}"
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
    "Version" : "2012-10-17",
    "Statement" : [
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
          module.s3_bucket_logging_target.s3_bucket_arn,
          "${module.s3_bucket_logging_target.s3_bucket_arn}/*"
        ]
      },
      {
        "Sid" : "S3PolicyStmt-DO-NOT-MODIFY-1652337892133",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logging.s3.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "${module.s3_bucket_logging_target.s3_bucket_arn}/*"
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
    },
    {
      id     = "delete_old_versions"
      status = "Enabled"
      expiration = {
        days                         = 0
        expired_object_delete_marker = true
      }
      noncurrent_version_expiration = {
        noncurrent_days = 1
      }
    },
    {
      id     = "intelligent-tireling"
      status = "Enabled"
      transition = {
        days          = 0
        storage_class = "INTELLIGENT_TIERING"
      }
    }
  ]

  # aws_s3_bucket_intelligent_tiering_configuration
  intelligent_tiering = [
    {
      status = false
      tiering = {
        ARCHIVE_ACCESS = {
          days = 90
        }
        DEEP_ARCHIVE_ACCESS = {
          days = 180
        }
      }
    }
  ]
}

# resource "aws_s3_bucket_lifecycle_configuration" "example" {
#   bucket = module.s3_bucket_logging_target.s3_bucket_id

#   rule {
#     id     = "Allow small object transitions in INTELLIGENT_TIERING"
#     status = "Enabled"

#     filter {
#       object_size_greater_than = 131072 # /バイト単位 / (128KB)  128KB未満のオブジェクトはアクセス頻度の確認）が対象外のため。
#     }
#     noncurrent_version_expiration {
#       newer_noncurrent_versions = 3  // 非現行バージョンを3世代保持。それ以前の古いバージョンは削除される。
#       noncurrent_days           = 30 // オブジェクトが非現行バージョンになってから、アクション（削除や移行）が実行されるまでの日数
#     }
#     transition {
#       days          = 0 // オブジェクトが格納されて24h以内に移行
#       storage_class = "INTELLIGENT_TIERING"
#     }
#   }
# }

// ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_intelligent_tiering_configuration
# resource "aws_s3_bucket_intelligent_tiering_configuration" "example" {
#   bucket = module.s3_bucket_logging_target.s3_bucket_id
#   name   = "Intelligent-Tirering-Archive-Option"

#   tiering {
#     access_tier = "ARCHIVE_ACCESS"
#     days        = 90
#   }
#   tiering {
#     access_tier = "DEEP_ARCHIVE_ACCESS"
#     days        = 180
#   }
# }

##################################################################################
# AccessLog for ALB
##################################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#trivy:ignore:AVD-AWS-0089 // (LOW): Bucket has logging disabled
module "s3_bucket_alb_accesslog" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = true

  # aws_s3_bucket
  bucket              = "alb-accesslog-${data.aws_caller_identity.self.account_id}"
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
            "arn:aws:iam::${data.aws_caller_identity.self.account_id}:root",
            "arn:aws:iam::582318560864:root" // 東京リージョンにおけるALBのログ配信を管理するために使用される内部的なAWSアカウント
          ]
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${module.s3_bucket_alb_accesslog.s3_bucket_arn}/*/AWSLogs/${data.aws_caller_identity.self.account_id}/*",
        ]
      },
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
    },
    {
      id     = "Delete-Old-Versions"
      status = "Enabled"
      expiration = {
        days                         = 0
        expired_object_delete_marker = true
      }
      noncurrent_version_expiration = {
        noncurrent_days = 1
      }
    },
  ]
}

##################################################################################
# AccessLog for CloudFront
##################################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#trivy:ignore:AVD-AWS-0089 // (LOW): Bucket has logging disabled
module "s3_bucket_cdn_accesslog" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = true

  providers = {
    aws = aws.us-east-1
  }

  # aws_s3_bucket
  bucket              = "cdn-log-${data.aws_caller_identity.self.account_id}"
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
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "CloudFront_logging_Allow",
        "Effect" : "Allow",
        "Principal" : { "Service" : "cloudfront.amazonaws.com" },
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutBucketAcl",
          "s3:PutObject",
        ],
        "Resource" : [
          module.s3_bucket_cdn_accesslog.s3_bucket_arn,
          "${module.s3_bucket_cdn_accesslog.s3_bucket_arn}/*"
        ],
        "Condition" : {
          "StringLike" : {
            "AWS:SourceArn" : "arn:aws:cloudfront::${data.aws_caller_identity.self.account_id}:distribution/*"
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
        days = 30
      }
    },
    {
      id     = "Delete-Old-Versions"
      status = "Enabled"
      expiration = {
        days                         = 0
        expired_object_delete_marker = true
      }
      noncurrent_version_expiration = {
        noncurrent_days = 1
      }
    }
  ]
}

# resource "aws_s3_bucket_lifecycle_configuration" "cdn_log" {
#   bucket   = module.s3_bucket_cdn_log.s3_bucket_id
#   provider = aws.us-east-1

#   dynamic "rule" {
#     for_each = local.lifecycle_configuration

#     content {
#       id     = rule.value.id
#       status = rule.value.status

#       filter {
#         prefix = rule.value.prefix
#       }

#       dynamic "transition" {
#         for_each = rule.value.transitions

#         content {
#           days          = transition.value.days
#           storage_class = transition.value.storage_class
#         }
#       }

#       noncurrent_version_transition {
#         newer_noncurrent_versions = rule.value.nonself_version_transition.newer_nonself_versions
#         noncurrent_days           = rule.value.nonself_version_transition.nonself_days
#         storage_class             = rule.value.nonself_version_transition.storage_class
#       }
#     }
#   }
# }

################################################################################
# Static Site for Web
################################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_bucket_static_site_web" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = true

  # aws_s3_bucket
  bucket              = "static-site-web-${data.aws_caller_identity.self.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = module.s3_bucket_logging_target.s3_bucket_id
    target_prefix = replace(trimprefix(module.s3_bucket_static_site_web.s3_bucket_id, "-${data.aws_caller_identity.self.account_id}"), "-", "_")

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
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Sid" : "Allow StaticSite",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com",
        }
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          module.s3_bucket_static_site_web.s3_bucket_arn,
          "${module.s3_bucket_static_site_web.s3_bucket_arn}/*",
        ],
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : data.terraform_remote_state.development_network.outputs.cloudfront_arn_cdn_takehiro1111_com
          }
        }
      }
    ]
  })

  # aws_s3_bucket_lifecycle_configuration
  lifecycle_rule = [
    {
      id     = "Transition-Gracier"
      status = "Enabled"
      noncurrent_version_transition = {
        noncurrent_days = 0
        storage_class   = "GLACIER_IR"
      }
    },
    {
      id     = "Delete-Old-Versions"
      status = "Enabled"

      expiration = {
        days                         = 0
        expired_object_delete_marker = true
      }
      noncurrent_version_expiration = {
        newer_noncurrent_versions = 3
        noncurrent_days           = 1
      }
    },
  ]
}

##################################################################################
# VPC FlowLogs
##################################################################################
#::memo::
# VPCフローログのバケットポリシーはデフォルトで動的に作成されるため、ユーザー側での作成は不要。
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_bucket_vpc_flow_logs" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = true

  # aws_s3_bucket
  bucket              = "vpc-flow-logs-${data.aws_caller_identity.self.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

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
}

##################################################################################
# Athena
##################################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_bucket_athena" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = false

  # aws_s3_bucket
  bucket              = "athena-${data.aws_caller_identity.self.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = module.s3_bucket_logging_target.s3_bucket_id
    target_prefix = replace(trimprefix(module.s3_bucket_athena.s3_bucket_id, "-${data.aws_caller_identity.self.account_id}"), "-", "_")

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
}

########################################################################
# Athena Query Result
########################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_bucket_athena_query_result" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = true

  # aws_s3_bucket
  bucket              = "athena-result-vpc-flow-logs-${data.aws_caller_identity.self.account_id}"
  force_destroy       = true // 一時的な検証用に使用するバケットのため
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = module.s3_bucket_logging_target.s3_bucket_id
    target_prefix = replace(trimprefix(module.s3_bucket_athena_query_result.s3_bucket_id, "-${data.aws_caller_identity.self.account_id}"), "-", "_")

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


#####################################################################
# S3 Inventory Verification
#####################################################################
/* 
 * Athena
 */
# resource "aws_s3_bucket_inventory" "athena" {
#   bucket = aws_s3_bucket.athena.id
#   name   = "AthenaBucket-Inventory"
#   included_object_versions = "self" // 現在のバージョンのみを対象。
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
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = false

  # aws_s3_bucket
  bucket              = "s3-inventory-dist-${data.aws_caller_identity.self.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = module.s3_bucket_logging_target.s3_bucket_id
    target_prefix = replace(trimprefix(module.s3_inventory_dist.s3_bucket_id, "-${data.aws_caller_identity.self.account_id}"), "-", "_")
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
            "aws:SourceAccount" = data.aws_caller_identity.self.account_id,
            "s3:x-amz-acl"      = "bucket-owner-full-control"
          },
          ArnLike = {
            "aws:SourceArn" = [
              // インベントリレポートの送信元バケットを記載。
              module.s3_bucket_athena.s3_bucket_arn
            ]
          }
        }
      }
    ]
  })
}

# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_batch_operation_dist" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = false

  # aws_s3_bucket
  bucket              = "s3-batch-operation-dist-${data.aws_caller_identity.self.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = module.s3_bucket_logging_target.s3_bucket_id
    target_prefix = replace(trimprefix(module.s3_batch_operation_dist.s3_bucket_id, "-${data.aws_caller_identity.self.account_id}"), "-", "_")

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
            "aws:SourceAccount" = data.aws_caller_identity.self.account_id
          },
          ArnLike = {
            "aws:SourceArn" = [
              "arn:aws:s3::${data.aws_caller_identity.self.account_id}:job/*"
            ]
          }
        }
      }
    ]
  })
}

# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_batch_operation_report_dist" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = false

  # aws_s3_bucket
  bucket              = "s3-batch-operation-report-dist-${data.aws_caller_identity.self.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = module.s3_bucket_logging_target.s3_bucket_id
    target_prefix = replace(trimprefix(module.s3_batch_operation_report_dist.s3_bucket_id, "-${data.aws_caller_identity.self.account_id}"), "-", "_")

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
            "aws:SourceAccount" = data.aws_caller_identity.self.account_id
          },
          ArnLike = {
            "aws:SourceArn" = [
              "arn:aws:s3::${data.aws_caller_identity.self.account_id}:job/*"
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
module "s3_bucket_cloudwatchlogs_to_s3" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = false

  # aws_s3_bucket
  bucket              = "cloudwatchlogs-to-s3-${data.aws_caller_identity.self.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = module.s3_bucket_logging_target.s3_bucket_id
    target_prefix = replace(trimprefix(module.s3_bucket_cloudwatchlogs_to_s3.s3_bucket_id, "-${data.aws_caller_identity.self.account_id}"), "-", "_")

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
          Service = "logs.${data.aws_region.default.name}.amazonaws.com"
        },
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject",
        ]
        Resource = [
          module.s3_bucket_cloudwatchlogs_to_s3.s3_bucket_arn,
          "${module.s3_bucket_cloudwatchlogs_to_s3.s3_bucket_arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.self.account_id
          }
          ArnLike = {
            "aws:SourceArn" = [
              "arn:aws:logs:${data.aws_region.default.name}:${data.aws_caller_identity.self.account_id}:log-group:*"
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
      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        },
        {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }
      ]
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
module "s3_bucket_cloudwatchlogs_to_s3_us_east_1" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = false

  providers = {
    aws = aws.us-east-1
  }

  # aws_s3_bucket
  bucket              = "cloudwatchlogs-to-s3-${data.aws_caller_identity.self.account_id}-us-east-1"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = module.s3_bucket_logging_target.s3_bucket_id
    target_prefix = replace(trimprefix(module.s3_bucket_cloudwatchlogs_to_s3.s3_bucket_id, "-${data.aws_caller_identity.self.account_id}-us-east-1"), "-", "_")

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
          Service = "logs.us-east-1.amazonaws.com"
        },
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject",
        ]
        Resource = [
          module.s3_bucket_cloudwatchlogs_to_s3_us_east_1.s3_bucket_arn,
          "${module.s3_bucket_cloudwatchlogs_to_s3_us_east_1.s3_bucket_arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.self.account_id
          }
          ArnLike = {
            "aws:SourceArn" = [
              "arn:aws:logs:us-east-1:${data.aws_caller_identity.self.account_id}:log-group:*"
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
      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        },
      ]
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
# SAM Templates
########################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#trivy:ignore:AVD-AWS-0089 // (LOW): Bucket has logging disabled
module "s3_bucket_sam_deploy" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
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

########################################################################
# Firehose Delivery Logs
########################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "firehose_delivery_logs" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = false

  providers = {
    aws = aws.us-east-1
  }

  # aws_s3_bucket
  bucket              = "firehose-delivery-logs-${data.aws_caller_identity.self.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = module.s3_bucket_logging_target.s3_bucket_id
    target_prefix = replace(trimprefix(module.firehose_delivery_logs.s3_bucket_id, "-${data.aws_caller_identity.self.account_id}"), "-", "_")

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
  # attach_policy = true
  # policy = jsonencode({
  #   Version = "2012-10-17",
  #   Statement = [
  #     {
  #       Effect = "Allow",
  #       Principal = {
  #         AWS = aws_iam_role.firehose_delivery_role.arn
  #       },
  #       Action = [
  #         "s3:AbortMultipartUpload",
  #         "s3:GetBucketLocation",
  #         "s3:GetObject",
  #         "s3:ListBucket",
  #         "s3:ListBucketMultipartUploads",
  #         "s3:PutObject"
  #       ]
  #       Resource = [
  #         module.firehose_delivery_logs.s3_bucket_arn,
  #         "${module.firehose_delivery_logs.s3_bucket_arn}/*"
  #       ]
  #     }
  #   ]
  # })

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

########################################################################
# Lambda Event
########################################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3_bucket_lambda_event" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  create_bucket = false

  # aws_s3_bucket
  bucket              = "lambda-event-${data.aws_caller_identity.self.account_id}"
  force_destroy       = true // オブジェクトが入っていても強制的に削除可能
  object_lock_enabled = false

  # aws_s3_bucket_logging
  logging = {
    target_bucket = module.s3_bucket_logging_target.s3_bucket_id
    target_prefix = replace(trimprefix(module.s3_bucket_lambda_event.s3_bucket_id, "-${data.aws_caller_identity.self.account_id}"), "-", "_")

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
  # ref: https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/enable-access-logging.html
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
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectAcl"
        ]
        Resource = [
          module.s3_bucket_lambda_event.s3_bucket_arn,
          "${module.s3_bucket_lambda_event.s3_bucket_arn}/*",
        ]
      }
    ]
  })
}
