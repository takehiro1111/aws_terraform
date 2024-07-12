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


#==================
# EC2
#==================
resource "aws_instance" "this" {
  ami                         = "ami-027a31eff54f1fe4c" // 「Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type」のAMI
  subnet_id                   = var.subnet_id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true // グローバルIPの有効化
  iam_instance_profile        = var.iam_instance_profile

  //EC2インスタンスにデフォルトでアタッチされるEBSボリュームの設定
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    delete_on_termination = false
    encrypted             = true

    tags = {
      Name = "${var.root_volume_name}"
    }
  }

  tags = {
    Name = "${var.inastance_name}"
  }
}

#==================
# EBS
#==================

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
  name        = "${var.sg_name}-${var.env}"
  description = "${var.sg_name}-${var.env}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.sg_name}-${var.env}"
  }
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.this.id
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

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_common_resource ? 1 : 0

  name               = "bastionrole"
  assume_role_policy = data.aws_iam_policy_document.this.json

  dynamic "inline_policy" {
    for_each = var.create_inline_policy != "" ? [1] : []

    content {
      name   = var.inline_policy_name
      policy = var.inline_policy
    }
  }
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_common_resource ? 1 : 0

  name = "bastionrole"
  role = aws_iam_role.this[0].name
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_policy_attach" {
  count = var.create_common_resource ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "bastion_cloudwatch_policy_attach" {
  count = var.create_common_resource ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


####################
# CloudWatch Logs
####################

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
