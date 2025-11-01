
#######################################################
# IAM
#######################################################
resource "aws_iam_role" "dynamodb_access" {
  name = "dynamodb_access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Env           = "production"
    Configuration = "terraform"
  }
}

resource "aws_iam_policy" "dynamodb_access_policy" {
  name = "DynamoDBAccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.users.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_access" {
  role       = aws_iam_role.dynamodb_access.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

resource "aws_iam_instance_profile" "web_api_server_profile" {
  name = "web_api_server_instance_profile"
  role = aws_iam_role.dynamodb_access.name
}

resource "aws_iam_instance_profile" "job_worker_profile" {
  name = "job_worker_instance_profile"
  role = aws_iam_role.dynamodb_access.name
}

#######################################################
# SG
#######################################################
resource "aws_security_group" "job_worker_server" {
  name   = "job_worker_server"
  vpc_id = aws_vpc.main.id

  tags = {
    Env           = "production"
    Configuration = "terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_self_job_worker_server" {
  security_group_id            = aws_security_group.job_worker_server.id
  referenced_security_group_id = aws_security_group.job_worker_server.id
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"

  tags = {
    Env           = "production"
    Configuration = "terraform"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_job_worker_server" {
  security_group_id = aws_security_group.job_worker_server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Env           = "production"
    Configuration = "terraform"
  }
}


resource "aws_security_group" "web_api_server" {
  name        = "web_api_server"
  description = "Allow HTTP and HTTPS access from within the VPC for web API servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Env           = "production"
    Configuration = "terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_web_api_server" {
  security_group_id = aws_security_group.web_api_server.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443

  tags = {
    Env           = "production"
    Configuration = "terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_web_api_server" {
  security_group_id = aws_security_group.web_api_server.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80

  tags = {
    Env           = "production"
    Configuration = "terraform"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_web_api_server" {
  security_group_id = aws_security_group.web_api_server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Env           = "production"
    Configuration = "terraform"
  }
}

