/**
 * ## Description
 * SessionManagerを利用した踏み台インスタンス(EC2)を構築するモジュール
 *
 * ## Usage:
 *
 * ```hcl
 * module "palette_bastion" {
 *   source = "../../modules/ec2/bastion"
 *
 *   env       = "prod"
 *   vpc_id    = aws_vpc.vpc.id
 *   subnet_id = aws_subnet.sn_private_1.id
 *
 *   create_common_resource = true
 * }
 * ```
 */


####################
# EC2
####################

resource "aws_instance" "this" {
  # Amazon Linux 2
  ami                    = "ami-0521a4a0a1329ff86"
  instance_type          = var.instance_type
  key_name               = ""
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]

  # IAM Role
  iam_instance_profile = "EC2BastionRole"

  # EBS
  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "ebs-bastion-${var.env}"
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "required"
  }

  # Name Tag
  tags = {
    Name = "ec2-bastion-${var.env}"
  }
}

resource "aws_ebs_volume" "this_tmp" {
  count = var.create_tmp_ebs_resource ? 1 : 0

  availability_zone = var.availability_zone

  size       = var.ebs_size
  type       = var.ebs_type
  iops       = var.ebs_iops
  throughput = var.ebs_throughput
  encrypted  = var.ebs_encrypted

  tags = {
    Name = "ec2-bastion-${var.env}-tmp"
  }
}

resource "aws_volume_attachment" "this_tmp" {
  count = var.create_tmp_ebs_resource ? 1 : 0

  device_name = var.ebs_device_name
  volume_id   = aws_ebs_volume.this_tmp[0].id
  instance_id = aws_instance.this.id
}

####################
# Security Group
####################

resource "aws_security_group" "this" {
  name        = "security-bastion-${var.env}"
  description = "security-bastion-${var.env}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "security-bastion-${var.env}"
  }
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.this.id
  description       = "security-bastion-${var.env}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  #tfsec:ignore:aws-ec2-no-public-egress-sgr
  cidr_blocks = ["0.0.0.0/0"]
}

####################
# IAM Role
####################
module "iam_role_this" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.60.0"

  create_role = var.create_common_resource
  role_name   = "EC2BastionRole"

  create_custom_role_trust_policy = true
  custom_role_trust_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com"]
        }
      },
    ]
  })

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  inline_policy_statements = [
    {
      sid = "ForS3BucketAccess"
      actions = [
        "s3:GetObject",
        "s3:PutObject",
      ]
      effect    = "Allow"
      resources = var.iam_role_inlinepolicy_resources
    },
  ]

  create_instance_profile = true
}

####################
# CloudWatch Logs
####################
#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "this" {
  count = var.create_common_resource ? 1 : 0

  name = "/ssmlogs/bastion"
}


####################
# Session Manager
####################

resource "aws_ssm_document" "this" {
  count = var.create_common_resource ? 1 : 0

  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = <<DOC
{
    "schemaVersion": "1.0",
    "description": "Document to hold regional settings for Session Manager",
    "sessionType": "Standard_Stream",
    "inputs": {
        "idleSessionTimeout": "${var.idle_session_timeout}",
        "maxSessionDuration": "${var.max_session_duration}",
        "cloudWatchStreamingEnabled": true,
        "cloudWatchLogGroupName": "${aws_cloudwatch_log_group.this[0].name}",
        "cloudWatchEncryptionEnabled": false
    }
}
DOC
}
