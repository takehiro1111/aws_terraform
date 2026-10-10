#####################################################
# SNS（Cost Anomaly Detection → Chatbot）
#####################################################
#trivy:ignore:avd-aws-0095 //(HIGH): Topic does not have encryption enabled.
resource "aws_sns_topic" "anomaly" {
  name = local.name
}

data "aws_iam_policy_document" "anomaly_topic" {
  statement {
    sid     = "AllowCostAnomalyDetectionPublish"
    actions = ["sns:Publish"]
    principals {
      type        = "Service"
      identifiers = ["costalerts.amazonaws.com"]
    }
    resources = [aws_sns_topic.anomaly.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.self.account_id]
    }
  }
}

resource "aws_sns_topic_policy" "anomaly" {
  arn    = aws_sns_topic.anomaly.arn
  policy = data.aws_iam_policy_document.anomaly_topic.json
}
