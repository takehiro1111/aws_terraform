resource "aws_security_group" "frankfurt_ec2" {
  count = var.eu_central_1 ? 1 : 0

  vpc_id   = aws_vpc.frankfurt.id
  name     = "public-instance"
  provider = aws.eu-central-1

  dynamic "ingress" {
    for_each = local.ingress_web

    content {
      description = ingress.value[0]
      from_port   = ingress.value[1]
      to_port     = ingress.value[2]
      protocol    = ingress.value[3]
      cidr_blocks = [ingress.value[4]]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.value.full_open_ip]
  }
}

data "aws_iam_policy_document" "session_manager_frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  provider = aws.eu-central-1

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "session_manager_frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  name               = "batstion-ssm-eu-central"
  assume_role_policy = data.aws_iam_policy_document.session_manager_frankfurt.json
  provider           = aws.eu-central-1
}

resource "aws_iam_instance_profile" "session_manager_frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  name     = aws_iam_role.session_manager_frankfurt.name
  role     = aws_iam_role.session_manager_frankfurt.name
  provider = aws.eu-central-1
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instancecore_frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  role       = aws_iam_role.session_manager_frankfurt.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  provider   = aws.eu-central-1
}

resource "aws_iam_role_policy_attachment" "cloudWatch_agent_serverpolicy_frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  role       = aws_iam_role.session_manager_frankfurt.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  provider   = aws.eu-central-1
}

resource "aws_ssm_document" "session_manager_frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  name            = "session-manager"
  document_type   = "Session"
  document_format = "JSON"
  provider        = aws.eu-central-1

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      "idleSessionTimeout" : 60,
      "maxSessionDuration" : 60,
      "cloudWatchStreamingEnabled" : true,
      "cloudWatchLogGroupName" : "${aws_cloudwatch_log_group.public_instance.name}",
      "cloudWatchEncryptionEnabled" : false
    }
  })
}
