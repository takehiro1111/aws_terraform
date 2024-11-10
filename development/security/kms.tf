# #CloudWatch Logs-------------------------------------------
# resource "aws_kms_key" "cloudwatch_logs" {
#   description             = "CMK for CloudWatch Logs"
#   deletion_window_in_days = 7
#   enable_key_rotation     = true
# }

# resource "aws_kms_alias" "cloudwatch_logs" {
#   name          = "alias/cloudwatch_logs_second"
#   target_key_id = aws_kms_key.cloudwatch_logs.key_id
# }

# resource "aws_kms_key_policy" "cloudwatch_logs" {
#   key_id = aws_kms_key.cloudwatch_logs.key_id
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Id" : "key-default-1",
#     "Statement" : [
#       {
#         "Sid" : "Enable IAM User Permissions",
#         "Effect" : "Allow",
#         "Principal" : {
#           "AWS" : "arn:aws:iam::${data.aws_caller_identity.self.account_id}:root"
#         },
#         "Action" : "kms:*",
#         "Resource" : "*"
#       },
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "logs.${data.aws_region.default.name}.amazonaws.com"
#         },
#         "Action" : [
#           "kms:Encrypt*",
#           "kms:Decrypt*",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:Describe*"
#         ],
#         "Resource" : "*",
#         "Condition" : {
#           "ArnEquals" : {
#             "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${data.aws_region.default.name}:${data.aws_caller_identity.self.account_id}:log-group:*"
#           }
#         }
#       }
#     ]
#   })
# }
# #S3-------------------------------------------
# resource "aws_kms_key" "s3" {
#   description             = "CMK for s3bucket"
#   deletion_window_in_days = 7
#   enable_key_rotation     = true
# }

# resource "aws_kms_alias" "s3" {
#   name          = "alias/s3_second"
#   target_key_id = aws_kms_key.s3.key_id
# }

# resource "aws_kms_key_policy" "s3" {
#   key_id = aws_kms_key.s3.key_id
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Id" : "key-default-2",
#     "Statement" : [
#       {
#         "Sid" : "Enable IAM User Permissions",
#         "Effect" : "Allow",
#         "Principal" : {
#           "AWS" : "arn:aws:iam::${data.aws_caller_identity.self.account_id}:root"
#         },
#         "Action" : "kms:*",
#         "Resource" : "*"
#       },
#       {
#         "Sid" : "Allow CloudFront ServicePrincipal SSE-KMS",
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "cloudfront.amazonaws.com"
#         },
#         "Action" : [
#           "kms:Decrypt",
#           "kms:Encrypt",
#           "kms:GenerateDataKey*"
#         ],
#         "Resource" : "*",
#         "Condition" : {
#           "StringEquals" : {
#             "AWS:SourceArn" : data.terraroform_remote_state.development_network.outputs.cloudfront_arn_cdn_takehiro1111_com
#           }
#         }
#       },
#       {
#         "Sid" : "Allow vpc-flow-log",
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "delivery.logs.amazonaws.com"
#         },
#         "Action" : [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey"
#         ],
#         "Resource" : aws_kms_key.s3.arn
#       },
#       {
#         "Sid" : "Allow s3 bucket logging",
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "logging.s3.amazonaws.com"
#         },
#         "Action" : [
#           "kms:GenerateDataKey",
#           "kms:Decrypt",
#           "kms:DescribeKey",
#           "kms:CreateGrant",
#         ],
#         "Resource" : "*"
#         "Condition" : {
#           "ArnLike" : {
#             "aws:SourceArn" : [
#               data.terraform_remote_state.development_storage.outputs.s3_bucket_arn_static_site_web,
#               data.terraform_remote_state.development_storage.outputs.s3_bucket_arn_logging_target,
#               data.terraform_remote_state.development_state.outputs.s3_bucket_arn_tfstate
#             ]
#           }
#         }
#       }
#     ]
#   })
# }
