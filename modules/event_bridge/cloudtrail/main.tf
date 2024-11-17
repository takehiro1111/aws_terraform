################################################################################
# Common
################################################################################
data "aws_caller_identity" "self" {}

resource "aws_cloudwatch_event_bus" "this" {
  name = "CloudTrailResourceOperationAggregateEventBus"
}

resource "aws_cloudwatch_event_bus_policy" "this" {
  policy         = data.aws_iam_policy_document.this.json
  event_bus_name = aws_cloudwatch_event_bus.this.name
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "AllowAccountToPutEvents"
    effect = "Allow"
    actions = [
      "events:PutEvents",
    ]
    resources = [
      aws_cloudwatch_event_bus.this.arn,
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.self.account_id}:root"]
    }
  }
}

resource "aws_cloudwatch_event_rule" "resource_operation_aggregate" {
  depends_on = [aws_cloudwatch_event_bus.this]

  name           = "CloudTrailResourceOperationAggregate"
  description    = "CloudTrailResourceOperationAggregate"
  event_bus_name = "CloudTrailResourceOperationAggregateEventBus"
  state          = "ENABLED"

  event_pattern = <<EOF
{
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "readOnly": [false],
    "eventCategory": ["Management"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "resource_operation_aggregate" {
  depends_on = [aws_cloudwatch_event_bus.this]

  rule           = aws_cloudwatch_event_rule.resource_operation_aggregate.name
  target_id      = "CloudTrailResourceOperationAggregateTarget"
  arn            = aws_sns_topic.this.arn
  event_bus_name = "CloudTrailResourceOperationAggregateEventBus"
}

#tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "this" {
  name         = "CloudTrailResourceOperationNotify"
  display_name = "CloudTrailResourceOperationNotify"
  policy = jsonencode(
    {
      Id = "CloudTrailResourceOperationNotify"
      Statement = [
        {
          Sid = "default"
          Action = [
            "SNS:GetTopicAttributes",
            "SNS:SetTopicAttributes",
            "SNS:AddPermission",
            "SNS:RemovePermission",
            "SNS:DeleteTopic",
            "SNS:Subscribe",
            "SNS:ListSubscriptionsByTopic",
            "SNS:Publish",
          ]
          Condition = {
            StringEquals = {
              "AWS:SourceOwner" = data.aws_caller_identity.self.account_id
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Resource = "arn:aws:sns:ap-northeast-1:${data.aws_caller_identity.self.account_id}:CloudTrailResourceOperationNotify"
        },
        {
          Sid    = "eventAllow"
          Action = "sns:Publish"
          Effect = "Allow"
          Principal = {
            Service = "events.amazonaws.com"
          }
          Resource = "arn:aws:sns:ap-northeast-1:${data.aws_caller_identity.self.account_id}:CloudTrailResourceOperationNotify"
        },
      ]
      Version = "2008-10-17"
    }
  )
}

resource "aws_sns_topic_subscription" "this" {
  endpoint                        = "https://global.sns-api.chatbot.amazonaws.com"
  protocol                        = "https"
  raw_message_delivery            = false
  topic_arn                       = aws_sns_topic.this.arn
  confirmation_timeout_in_minutes = 1
  endpoint_auto_confirms          = false
}


################################################################################
# ap-northeast-1
################################################################################
resource "aws_cloudwatch_event_rule" "resource_operation_tokyo" {
  name        = "CloudTrailResourceOperationTokyo"
  description = "CloudTrailResourceOperationTokyo"
  state       = "ENABLED"

  event_pattern = <<EOF
{
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "readOnly": [false],
    "eventCategory": ["Management"],
    "eventName": [{
      "anything-but": ["StartSession", "TerminateSession", "ResumeSession"]
    }],
    "userIdentity": {
      "arn": [{
        "prefix": "arn:aws:sts::${data.aws_caller_identity.self.account_id}:assumed-role/AWSReservedSSO"
      }]
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "resource_operation_tokyo" {
  rule      = aws_cloudwatch_event_rule.resource_operation_tokyo.name
  target_id = "CloudTrailResourceOperationTokyo"
  arn       = aws_cloudwatch_event_bus.this.arn
  role_arn  = aws_iam_role.event_target.arn
}

resource "aws_iam_role" "event_target" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "events.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "EventBridge_Invoke_Event_Bus"
  path                  = "/service-role/"
}

resource "aws_iam_role_policy_attachments_exclusive" "event_target" {
  role_name   = aws_iam_role.event_target.name
  policy_arns = [aws_iam_policy.this.arn]
}

resource "aws_iam_policy" "this" {
  name = "EventBridge_Invoke_Event_Bus"
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "events:PutEvents",
          ]
          Effect = "Allow"
          Resource = [
            aws_cloudwatch_event_bus.this.arn,
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}

################################################################################
# us-east-1
################################################################################
resource "aws_cloudwatch_event_rule" "resource_operation_virginia" {
  provider    = aws.us-east-1
  name        = "CloudTrailResourceOperationVirginia"
  description = "CloudTrailResourceOperationVirginia"
  state       = "ENABLED"

  event_pattern = <<EOF
{
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "readOnly": [false],
    "eventCategory": ["Management"],
    "eventName": [{
      "anything-but": ["StartSession", "TerminateSession", "ResumeSession"]
    }],
    "userIdentity": {
      "arn": [{
        "prefix": "arn:aws:sts::${data.aws_caller_identity.self.account_id}:assumed-role/AWSReservedSSO"
      }]
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "resource_operation_virginia" {
  provider  = aws.us-east-1
  rule      = aws_cloudwatch_event_rule.resource_operation_virginia.name
  target_id = "CloudTrailResourceOperationVirginia"
  arn       = aws_cloudwatch_event_bus.this.arn
  role_arn  = aws_iam_role.event_target.arn
}
