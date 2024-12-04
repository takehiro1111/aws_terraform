# vpc-flow-log ---------------------------------------------------------
# to CloludWatch Logs
# resource "aws_iam_role" "flow_log" {
#   name = "vpc-flow-log"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "vpc-flow-logs.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# data "aws_iam_policy_document" "flow_log" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams"
#     ]
#     resources = [
#       "${aws_cloudwatch_log_group.flow_log.arn}:*",
#     ]
#   }
#   statement {
#     effect = "Allow"
#     actions = [
#       "firehose:PutRecord",
#       "firehose:PutRecordBatch",
#     ]
#     resources = [
#       "*", // Firehoseのresourceを指定予定
#     ]
#   }
# }

# resource "aws_iam_role_policy" "flow_log" {
#   name   = aws_iam_role.flow_log.name
#   role   = aws_iam_role.flow_log.name
#   policy = data.aws_iam_policy_document.flow_log.json
# }

#ECS タスクロール--------------------------------------------------------
// ECSタスク内のコンテナがAWSリソースへアクセスするためのロール。
// タスク内で動作するアプリケーションがS3、DynamoDB、SQSなどの他のAWSサービスにアクセスする必要がある場合に、このロールを使用する。
module "ecs_task_role_web" {
  source     = "../../modules/iam/assume_role"
  name       = "ecs-task-role@web"
  policy     = data.aws_iam_policy_document.ecs_task.json
  identifier = "ecs-tasks.amazonaws.com"
}

data "aws_iam_policy" "ecs_task_execution_role_policy_source" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task" {
  source_policy_documents = [data.aws_iam_policy.ecs_task_execution_role_policy_source.policy]

  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParameters",
      "kms:Decrypt",
      "secretsmanager:GetSecretValue",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "logs:CreateLogGroup"
    ]
    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = ["*"]
  }
}

# ECS タスク実行ロール ----------------------------------------------
// プライベートサブネットにECSを配置する場合、ECRとのpull,push等のために必要。
//  ECSエージェントがECSタスクを起動するために使用するIAMロール。
module "ecs_task_execute_role_web" {
  source     = "../../modules/iam/assume_role"
  name       = "ecs-task-execute-role@web"
  policy     = data.aws_iam_policy_document.ecs_task_execute_web.json
  identifier = "ecs-tasks.amazonaws.com"
}

data "aws_iam_policy" "ecs_task_execute_web" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy_document" "ecs_task_execute_web" {
  source_policy_documents = [data.aws_iam_policy.ecs_task_execute_web.policy]

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
    ]
    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = ["*"]
  }
}

# CodeDeploy for ECS ----------------------------------------------------------------
module "codedeploy_for_ecs_role" {
  source = "../../modules/iam/codedeploy_for_ecs"
}

# Github Actions --------------------------------------------------------------------
# OIDCプロバイダ
module "oidc" {
  source = "../../modules/iam/oidc"
}

# GithubActions用のIAMロール,ポリシー --------------------------------------------------
// IAMロール,信頼ポリシーの設定
resource "aws_iam_role" "deploy_github_actions" {
  name = "deploy-github-actions"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow"
        Principal = {
          Federated = module.oidc.oidc_arn
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : [
              "repo:takehiro1111/aws_terraform:*",
              "repo:takehiro1111/github_terraform:*",
              "repo:takehiro1111/ecs-learning-course:*",
              "repo:takehiro1111/docker:*",
              "repo:takehiro1111/serverless:*",
            ]
          }
        }
      }
    ]
  })
}

// 許可ポリシーの設定。
data "aws_iam_policy_document" "deploy_github_actions" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "s3-object-lambda:*"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "GithubActions"
    effect    = "Allow"
    actions   = ["sts:*"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/myaccount_actions"]
  }
  statement {
    sid    = "GetItem"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]
    resources = ["arn:aws:dynamodb:ap-northeast-1:${data.aws_caller_identity.self.account_id}:table/tfstate-locks"]
  }
  statement {
    sid       = "PushECR"
    effect    = "Allow"
    actions   = ["ecr:*"]
    resources = ["*"]
  }
  statement {
    sid       = "DeployECS"
    effect    = "Allow"
    actions   = ["ecs:*"]
    resources = ["*"]
  }
  statement {
    sid     = "PassRole"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/ecsTaskExecutionRole",
      "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/secure-ecs-tasks-stg@common"
    ]
  }
  statement {
    sid     = "ALL"
    effect  = "Allow"
    actions = ["*"]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "deploy_github_actions" {
  name   = aws_iam_role.deploy_github_actions.name
  role   = aws_iam_role.deploy_github_actions.name
  policy = data.aws_iam_policy_document.deploy_github_actions.json
}

/* 
 * Workflow for handling WAF RegionalLimit
 */
resource "aws_iam_role" "github_actions_for_waf" {
  name = "deploy-github-actions-for-waf"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow"
        Principal = {
          Federated = module.oidc.oidc_arn
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : [
              "repo:takehiro1111/aws_terraform:*",
            ]
          }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "github_actions_for_waf" {
  statement {
    effect = "Allow"
    actions = [
      "wafv2:UpdateWebACL",
      "wafv2:ListWebACLs",
      "wafv2:GetWebACL",
      "wafv2:DeleteRule",
      "wafv2:CreateRule",
      "wafv2:ListTagsForResource",
    ]
    resources = ["arn:aws:wafv2:us-east-1:${data.aws_caller_identity.self.account_id}:global/webacl/*/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = ["${data.terraform_remote_state.development_state.outputs.s3_bucket_arn_tfstate}/*"]
  }
  # statement {
  #   effect = "Allow"
  #   actions = [
  #     "dynamodb:GetItem",
  #     "dynamodb:PutItem",
  #   ]
  #   resources = [aws_dynamodb_table.tfstate_locks.arn]
  # }
  # statement {
  #   effect    = "Allow"
  #   actions   = ["*"]
  #   resources = ["*"]
  # }
}

resource "aws_iam_role_policy" "github_actions_for_waf" {
  name   = aws_iam_role.github_actions_for_waf.name
  role   = aws_iam_role.github_actions_for_waf.name
  policy = data.aws_iam_policy_document.github_actions_for_waf.json
}

/* 
 * Session Manager
 */
data "aws_iam_policy_document" "session_manager" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "session_manager" {
  name               = "batstion-ssm"
  assume_role_policy = data.aws_iam_policy_document.session_manager.json
}

resource "aws_iam_instance_profile" "session_manager" {
  name = aws_iam_role.session_manager.name
  role = aws_iam_role.session_manager.name
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instancecore" {
  role       = aws_iam_role.session_manager.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudWatch_agent_serverpolicy" {
  role       = aws_iam_role.session_manager.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_ssm_document" "session_manager" {
  name            = "session-manager"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      "idleSessionTimeout" : 60,
      "maxSessionDuration" : 60,
      "cloudWatchStreamingEnabled" : true,
      "cloudWatchLogGroupName" : data.terraform_remote_state.development_management.outputs.cw_log_group_name_public_instance,
      "cloudWatchEncryptionEnabled" : false
    }
  })
}

/* 
 * ECS
 */
data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution_policy_doc" {
  source_policy_documents = [data.aws_iam_policy.ecs_task_execution.policy]

  statement {
    effect = "Allow"
    actions = [
      "ssm:Getparameters",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

/* 
 * Lambda WAF Create Delete Execute Role
 */
resource "aws_iam_role" "lambda_execute_waf" {
  name = "lambda-execute-waf"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "lambda_execute_waf" {
  statement {
    effect = "Allow"
    actions = [
      "wafv2:CreateRule",
      "wafv2:DeleteRule",
      "wafv2:UpdateWebACL",
      "wafv2:GetWebACL",
      "wafv2:ListWebACLs"
    ]
    resources = ["arn:aws:wafv2:us-east-1:${data.aws_caller_identity.self.account_id}:global/webacl/*/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.default.name}:${data.aws_caller_identity.self.account_id}:log-group:*:*"]
  }
}

resource "aws_iam_role_policy" "lambda_execute_waf" {
  name   = aws_iam_role.lambda_execute_waf.name
  role   = aws_iam_role.lambda_execute_waf.name
  policy = data.aws_iam_policy_document.lambda_execute_waf.json
}


/* 
 * Lambda Common Excecute Role
 */
resource "aws_iam_role" "lambda_execute" {
  name = "lambda-execute-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.lambda_execute.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {
  role       = aws_iam_role.lambda_execute.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "aws_iam_policy_document" "lambda_execute" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:${data.aws_caller_identity.self.account_id}:log-group:*:*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = ["arn:aws:sns:*:${data.aws_caller_identity.self.account_id}:*"]
  }
}

resource "aws_iam_role_policy" "lambda_execute" {
  name   = aws_iam_role.lambda_execute.name
  role   = aws_iam_role.lambda_execute.name
  policy = data.aws_iam_policy_document.lambda_execute.json
}

/* 
 * S3 Batch Operation
 */
resource "aws_iam_role" "s3_batch_operation" {
  name = "s3-batch-operation"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "batchoperations.s3.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "s3_batch_operation" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = ["arn:aws:kms:${data.aws_region.default.name}:${data.aws_caller_identity.self.account_id}:key/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]
    resources = ["arn:aws:s3:::*"]
  }
}

resource "aws_iam_role_policy" "s3_batch_operation" {
  name   = aws_iam_role.s3_batch_operation.name
  role   = aws_iam_role.s3_batch_operation.name
  policy = data.aws_iam_policy_document.s3_batch_operation.json
}

/**
 * For Firehose
 */
resource "aws_iam_role" "firehose_delivery_role" {
  name        = "firehose-stg@delivery_role"
  description = "firehose delivery role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${data.aws_caller_identity.self.account_id}"
        }
      }
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "firehose_delivery_role" {
  role       = aws_iam_role.firehose_delivery_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role" "glue_crawler_vpc_flow_logs" {
  name = "glue_crawler_role_vpc_flow_logs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_crawler_vpc_flow_logs" {
  role       = aws_iam_role.glue_crawler_vpc_flow_logs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# resource "aws_iam_role_policy" "glue_crawler_vpc_flow_logs" {
#   role = aws_iam_role.glue_crawler_vpc_flow_logs.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetBucketLocation",
#           "s3:ListBucket",
#           "s3:GetObject"
#         ]
#         Resource = [
#           module.s3_for_vpc_flow_log_stg.s3_bucket_arn,
#           "${module.s3_for_vpc_flow_log_stg.s3_bucket_arn}/*"
#         ]
#       }
#     ]
#   })
# }

/* 
 * 他アカウントのLambdaへパスロール
 */
resource "aws_iam_role" "monitor_waf_rule" {
  name = "monitor-waf-rule"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::421643133281:role/monitor-waf-rule-lambda-execution-role",
            "arn:aws:iam::789003075721:role/monitor-waf-lambda-execution-role",
          ]
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "monitor_waf_rule" {
  statement {
    effect = "Allow"
    actions = [
      "wafv2:ListWebACLs",
      "wafv2:GetWebACL",
    ]
    resources = ["arn:aws:wafv2:us-east-1:${data.aws_caller_identity.self.account_id}:global/webacl/*/*"]
  }
}

resource "aws_iam_role_policy" "monitor_waf_rule" {
  name   = aws_iam_role.monitor_waf_rule.name
  role   = aws_iam_role.monitor_waf_rule.name
  policy = data.aws_iam_policy_document.monitor_waf_rule.json
}

/* 
 * Chatbot
 */
resource "aws_iam_role" "chatbot" {
  name                  = "AWSChatbot-role"
  description           = "AWS Chatbot Execution Role"
  path                  = "/service-role/"
  force_detach_policies = false
  max_session_duration  = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      }
    ]
  })
}

# 想定外のエラーにならないよう、デフォルトのテンプレートポリシーに沿った設定しているためワイルドーカードで定義している。
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "chatbot" {
  statement {
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "chatbot" {
  name   = aws_iam_role.chatbot.name
  role   = aws_iam_role.chatbot.name
  policy = data.aws_iam_policy_document.chatbot.json
}
