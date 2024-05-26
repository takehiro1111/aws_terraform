resource "aws_iam_role" "default" {
  name               = var.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action  = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
              Service = "${var.identifier}"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "default" {
  name   = var.name
  policy = var.policy
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}


