#####################################################
# IAM Role（development の Lambda が AssumeRole して Cost Explorer を読む）
#####################################################
data "aws_iam_policy_document" "assume_from_hub" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.development_account_id}:role/${local.hub_role_name}"]
    }
  }
}

resource "aws_iam_role" "reader" {
  name               = "all-accounts-cost-alert-reader"
  assume_role_policy = data.aws_iam_policy_document.assume_from_hub.json
}

data "aws_iam_policy_document" "read_cost" {
  statement {
    sid       = "ReadCostAndUsage"
    actions   = ["ce:GetCostAndUsage"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "read_cost" {
  name   = "all-accounts-cost-alert-reader-read-cost"
  role   = aws_iam_role.reader.id
  policy = data.aws_iam_policy_document.read_cost.json
}
