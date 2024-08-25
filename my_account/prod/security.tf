
#####################################################
# IAM
#####################################################
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

#####################################################
# WAF
#####################################################
resource "aws_wafv2_web_acl" "regional_limit" {
  count = var.waf_regional_limit ? 1 : 0

  name        = "regionallimit"
  description = "prod.waf.com / prod.waf.com"
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
