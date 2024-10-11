#####################################################
# Security Group
#####################################################
# ALB--------------------------------------
resource "aws_security_group" "alb_stg" {
  name        = "alb-stg"
  description = "Allow inbound alb"
  vpc_id      = module.vpc_common.vpc_id

  tags = {
    "Name" = "alb-stg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_stg_443" {
  security_group_id = aws_security_group.alb_stg.id
  description       = "Allow inbound rule for https"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cdn.id

  tags = {
    Name = "alb-stg-443"
  }
}

resource "aws_vpc_security_group_egress_rule" "alb_stg_eggress" {
  security_group_id = aws_security_group.alb_stg.id
  description       = "Allow outbound rule for all"
  ip_protocol       = "all"
  cidr_ipv4         = module.value.full_open_ip

  tags = {
    Name = "alb-stg-egress"
  }
}

resource "aws_security_group" "alb_9000" {
  name        = "alb-9000"
  description = "Allow inbound alb"
  vpc_id      = module.vpc_common.vpc_id

  tags = {
    "Name" = "alb-9000"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_stg_9000_cdn" {
  security_group_id = aws_security_group.alb_9000.id
  description       = "Allow developers for blue-green deployments"
  from_port         = 9000
  to_port           = 9000
  ip_protocol       = "tcp"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cdn.id

  tags = {
    Name = "alb-stg-9000-cdn"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_stg_9000_myip" {
  for_each = module.value.my_ips

  security_group_id = aws_security_group.alb_9000.id
  description       = "Allow developers for blue-green deployments"
  from_port         = 9000
  to_port           = 9000
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value

  tags = {
    Name = "alb-stg-9000-my-ip"
  }
}

resource "aws_vpc_security_group_egress_rule" "alb_9000_eggress" {
  security_group_id = aws_security_group.alb_9000.id
  description       = "Allow outbound rule for all"
  ip_protocol       = "all"
  cidr_ipv4         = module.value.full_open_ip

  tags = {
    Name = "alb-9000-egress"
  }
}

# ECS & EC2 ------------------------------------
resource "aws_security_group" "ecs_stg" {
  name        = "ecs-stg"
  description = "Allow inbound alb"
  vpc_id      = module.vpc_common.vpc_id

  tags = {
    "Name" = "ecs-stg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_stg_for_alb" {
  security_group_id            = aws_security_group.ecs_stg.id
  description                  = "Allow inbound rule alb"
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb_stg.id

  tags = {
    "Name" = "ecs-stg-for-alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "between_ecs" {
  security_group_id            = aws_security_group.ecs_stg.id
  description                  = "Allow inbound rule ecs"
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_stg.id

  tags = {
    "Name" = "ecs-stg-between-ecs"
  }
}

resource "aws_vpc_security_group_egress_rule" "ecs_stg_egress" {
  security_group_id = aws_security_group.ecs_stg.id
  description       = "Allow outbound rule for all"
  ip_protocol       = "all"
  cidr_ipv4         = module.value.full_open_ip

  tags = {
    Name = "ecs-stg-egress"
  }
}

#MySQL ------------------------------------- 
module "sg_mysql" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  // SG本体
  name        = "aurora-mysql"
  description = "SecurityGroup for Aurora MySQL"
  vpc_id      = module.vpc_common.vpc_id
  // ルール
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from VPC"
      cidr_blocks = join(",", [
        module.value.subnet_ip_common.a_private,
        module.value.subnet_ip_common.c_private,
        module.value.subnet_ip_common.d_private
      ])
    }
  ]
  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "MySQL Inbound from Source SG"
      source_security_group_id = aws_security_group.ecs_stg.id
    }
  ]
  ingress_with_prefix_list_ids = [
    {
      from_port               = 443
      to_port                 = 443
      protocol                = "tcp"
      description             = "Allow Inbound From CloludFront"
      ingress_prefix_list_ids = data.aws_ec2_managed_prefix_list.cdn.id
    }
  ]

  egress_rules = ["all-all"]
}

resource "aws_vpc_security_group_ingress_rule" "mysql_stg_cdn" {
  security_group_id = module.sg_mysql.security_group_id
  description       = "Allow inbound rule for https"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cdn.id

  tags = {
    Name = "mysql-stg-cdn"
  }
}


module "vpc_endpoint" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  // SG
  name        = "stats-fluentd"
  description = "SG for log routing"
  vpc_id      = module.vpc_common.vpc_id
  // Rule
  ingress_with_source_security_group_id = [
    {
      from_port                = 24224
      to_port                  = 24224
      protocol                 = "tcp"
      description              = "Log Routing"
      source_security_group_id = aws_security_group.ecs_stg.id
    }
  ]

  egress_rules = ["all-all"]
}

#####################################################
# IAM
#####################################################
# vpc-flow-log ---------------------------------------------------------
# to CloludWatch Logs
resource "aws_iam_role" "flow_log" {
  name = "vpc-flow-log"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "flow_log" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "${aws_cloudwatch_log_group.flow_log.arn}:*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [
      "*", // Firehoseのresourceを指定予定
    ]
  }
}

resource "aws_iam_policy" "flow_log" {
  name   = "cloudwatch-logs-create-put"
  policy = data.aws_iam_policy_document.flow_log.json
}

resource "aws_iam_role_policy_attachment" "flow_log" {
  role       = aws_iam_role.flow_log.name
  policy_arn = aws_iam_policy.flow_log.arn
}

#ECS Task用ロール--------------------------------------------------------
module "ecs_task_stg" {
  source     = "../modules/iam/assume_role"
  name       = "secure-ecs-tasks-stg@common"
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
data "aws_iam_role" "ecs_task_execute" {
  name = "ecsTaskExecutionRole"
}
// プライベートサブネットにECSを配置する場合、ECRとのpull,push等のために必要。
data "aws_iam_policy" "ecs_task_execute" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy_document" "ecs_task_execute" {
  source_policy_documents = [data.aws_iam_policy.ecs_task_execute.policy]

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup"
    ]
    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_execute" {
  name   = data.aws_iam_role.ecs_task_execute.name
  role   = data.aws_iam_role.ecs_task_execute.name
  policy = data.aws_iam_policy_document.ecs_task_execute.json
}

# CodeDeploy for ECS ----------------------------------------------------------------
module "codedeploy_for_ecs_role" {
  source = "../modules/iam/codedeploy_for_ecs"
}

# Github Actions --------------------------------------------------------------------
# OIDCプロバイダ
module "oidc" {
  source = "../modules/iam/oidc"
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
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/myaccount_actions"]
  }
  statement {
    sid    = "GetItem"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]
    resources = ["arn:aws:dynamodb:ap-northeast-1:${data.aws_caller_identity.current.account_id}:table/tfstate-locks"]
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
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/secure-ecs-tasks-stg@common"
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
    resources = ["arn:aws:wafv2:us-east-1:${data.aws_caller_identity.current.account_id}:global/webacl/*/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = ["${aws_s3_bucket.tfstate.arn}/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]
    resources = [aws_dynamodb_table.tfstate_locks.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions_for_waf" {
  name   = aws_iam_role.github_actions_for_waf.name
  role   = aws_iam_role.github_actions_for_waf.name
  policy = data.aws_iam_policy_document.github_actions_for_waf.json
}

# Session Manager ---------------------------------------------------------------------
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
      "cloudWatchLogGroupName" : "${aws_cloudwatch_log_group.public_instance.name}",
      "cloudWatchEncryptionEnabled" : false
    }
  })
}

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
    resources = ["arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*:*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = ["arn:aws:sns:*:${data.aws_caller_identity.current.account_id}:*"]
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
    resources = ["arn:aws:kms:${data.aws_region.default.name}:${data.aws_caller_identity.current.account_id}:key/*"]
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

# Chatbot ---------------------------------------------------------------------
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
          "sts:ExternalId": "${data.aws_caller_identity.current.account_id}"
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

resource "aws_iam_role_policy" "glue_crawler_vpc_flow_logs" {
  role = aws_iam_role.glue_crawler_vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          module.s3_for_vpc_flow_log_stg.s3_bucket_arn,
          "${module.s3_for_vpc_flow_log_stg.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

#####################################################
# KMS
#####################################################
#CloudWatch Logs-------------------------------------------
resource "aws_kms_key" "cloudwatch_logs" {
  description             = "CMK for CloudWatch Logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "cloudwatch_logs" {
  name          = "alias/cloudwatch_logs_second"
  target_key_id = aws_kms_key.cloudwatch_logs.key_id
}

resource "aws_kms_key_policy" "cloudwatch_logs" {
  key_id = aws_kms_key.cloudwatch_logs.key_id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "key-default-1",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::421643133281:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logs.ap-northeast-1.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" : "*",
        "Condition" : {
          "ArnEquals" : {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:ap-northeast-1:421643133281:log-group:*"
          }
        }
      }
    ]
  })
}
#S3-------------------------------------------
resource "aws_kms_key" "s3" {
  description             = "CMK for s3bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "s3" {
  name          = "alias/s3_second"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_kms_key_policy" "s3" {
  key_id = aws_kms_key.s3.key_id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "key-default-2",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow CloudFront ServicePrincipal SSE-KMS",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : module.cdn_takehiro1111_com.cloudfront_distribution_arn
          }
        }
      },
      {
        "Sid" : "Allow vpc-flow-log",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "delivery.logs.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : aws_kms_key.s3.arn
      },
      {
        "Sid" : "Allow s3 bucket logging",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logging.s3.amazonaws.com"
        },
        "Action" : [
          "kms:GenerateDataKey",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:CreateGrant",
        ],
        "Resource" : "*"
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : [
              aws_s3_bucket.tfstate.arn,
              aws_s3_bucket.logging.arn,
              aws_s3_bucket.cdn_log.arn,
            ]
          }
        }
      }
    ]
  })
}

#####################################################
# WAF
#####################################################
resource "aws_wafv2_web_acl" "region_count" {
  count = var.waf_region_count ? 1 : 0

  name        = "common-web-acl"
  scope       = "CLOUDFRONT"
  description = "ACL for allowing specific regions"
  provider    = aws.us-east-1

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.waf_rule_regional_limit ? [1] : []
    content {
      name     = "RegionalLimit"
      priority = 1

      action {
        block {}
      }

      statement {
        not_statement {
          statement {
            geo_match_statement {
              country_codes = ["JP", "US", "SG"]
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "RegionalLimit"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "exampleWebACL"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl" "regional_limit" {
  count = var.waf_regional_limit ? 1 : 0

  name        = "regionallimit"
  description = "Example WebACL"
  scope       = "CLOUDFRONT"
  provider    = aws.us-east-1

  default_action {
    allow {}
  }

  rule {
    name     = "RegionalLimit"
    priority = 0

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.regional_limit[0].arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RegionalLimit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "regionallimit"
    sampled_requests_enabled   = true
  }
}

# ルールグループの作成
resource "aws_wafv2_rule_group" "regional_limit" {
  count = var.waf_regional_limit ? 1 : 0

  name     = "RegionalLimit"
  scope    = "CLOUDFRONT"
  capacity = 50
  provider = aws.us-east-1

  rule {
    name     = "RegionalLimit"
    priority = 0

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = ["JP", "US", "SG"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RegionalLimit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "RegionalLimit"
    sampled_requests_enabled   = true
  }
}
