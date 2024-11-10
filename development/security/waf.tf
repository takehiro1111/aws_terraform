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
