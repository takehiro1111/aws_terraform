#########################################################
# IAM Policy of Permission Set
#########################################################
resource "aws_iam_policy" "support_user_customer_managed_policy" {
  name        = "supportuser-customer-managed-policy"
  description = "supportuser-customer-managed-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ]
        Effect   = "Deny"
        Resource = data.terraform_remote_state.master_state_prod.outputs.state_s3_bucket_arn
      },
    ]
  })
}
