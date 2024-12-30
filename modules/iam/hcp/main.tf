locals {
  tfc_hostname = "app.terraform.io"
}

data "tls_certificate" "this" {
  url = "https://${local.tfc_hostname}"
}

resource "aws_iam_openid_connect_provider" "this" {
  url             = data.tls_certificate.this.url
  client_id_list  = ["aws.workload.identity"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "this" {
  name = "tfc-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${aws_iam_openid_connect_provider.this.arn}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.tfc_hostname}:aud": "${one(aws_iam_openid_connect_provider.this.client_id_list)}"
          },
          "StringLike": {
            "${local.tfc_hostname}:sub": "organization:${var.hcp_org_name}:project:*:workspace:*:run_phase:*"
          }
        }
      }
    ]
  }
EOF
}

resource "aws_iam_policy" "this" {
  name        = "tfc-policy"
  description = "TFC run policy"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": ["*"],
        "Resource": "*"
      }
    ]
  }
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
