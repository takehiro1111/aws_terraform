resource "aws_iam_user" "this" {
  name          = var.user_name
  path          = var.path
  force_destroy = var.force_destroy
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

data "aws_iam_policy_document" "this" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "this" {
  name   = var.user_name
  user   = aws_iam_user.this.name
  policy = data.aws_iam_policy_document.this.json
}