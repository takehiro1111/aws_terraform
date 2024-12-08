#################################################################################
# EC2 Instance
################################################################################
data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.20241121.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazonの所有者ID
}

resource "aws_instance" "web_server" {
  count = var.create_web_server ? 1 : 0

  ami                         = "ami-027a31eff54f1fe4c" // 「Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type」のAMI
  subnet_id                   = data.terraform_remote_state.development_network.outputs.private_subnet_a_development
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [data.terraform_remote_state.development_security.outputs.sg_id_ec2]
  associate_public_ip_address = false // SessionManagerでのログインに絞りたいためGIPの付与は行わない。
  iam_instance_profile        = data.terraform_remote_state.development_security.outputs.iam_instance_profile_session_manager

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = false
    encrypted             = true

    tags = {
      Name = "web-server-root-volume-${count.index}"
    }
  }

  tags = {
    Name = "common-instance"
  }
}

resource "aws_ec2_instance_state" "web_server" {
  count = var.create_web_server ? 1 : 0

  instance_id = aws_instance.web_server["*"].id
  state       = "stopped"
}

/*
 * Prometheus Server 
 */
module "ec2_prometheus_server" {
  source = "../../modules/ec2/general_instance"

  env = "stg"
  ec2_instance = {
    state                             = "running"
    inastance_name                    = "prometheus-server"
    ami                               = "ami-0037237888be2fe22"
    instance_type                     = "t3.micro"
    subnet_id                         = data.terraform_remote_state.development_network.outputs.public_subnet_a_development
    vpc_security_group_ids            = [data.terraform_remote_state.development_security.outputs.sg_id_ec2_ssm]
    iam_instance_profile              = aws_iam_instance_profile.this.name
    associate_public_ip_address       = true
    create_additonal_ebs_block_device = false
    root_block_device = {
      type                  = "gp3"
      size                  = 30
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options = {
    http_tokens = "required"
  }

  # https://grafana.com/grafana/download
  # OSSのエディションを選択
  # EC2用 ※ディストリビューションによってパッケージを選択する。
  # ref: https://zenn.dev/takehiro1111/articles/prometheus_grafana_20240303
  user_data = <<END
    #!/bin/bash
    cd ~
    sudo yum install -y https://dl.grafana.com/oss/release/grafana-11.3.2-1.x86_64.rpm
    sudo systemctl start grafana-server
    sudo systemctl enable grafana-server
    sudo wget https://github.com/prometheus/prometheus/releases/download/v2.53.3/prometheus-2.53.3.linux-amd64.tar.gz
    /bin/tar -zxvf prometheus-2.53.3.linux-amd64.tar.gz

    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker

    wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.25.0/blackbox_exporter-0.25.0.linux-amd64.tar.gz
    /bin/tar -zxvf blackbox_exporter-0.25.0.linux-amd64.tar.gz
  END
}

/*
 * Node Exporter用 
 */
module "ec2_node_exporter" {
  source = "../../modules/ec2/general_instance"

  env = "stg"
  ec2_instance = {
    state                             = "running"
    inastance_name                    = "node-exporter"
    ami                               = "ami-0037237888be2fe22"
    instance_type                     = "t3.nano"
    subnet_id                         = data.terraform_remote_state.development_network.outputs.public_subnet_a_development
    vpc_security_group_ids            = [data.terraform_remote_state.development_security.outputs.sg_id_ec2_ssm]
    iam_instance_profile              = aws_iam_instance_profile.this.name
    associate_public_ip_address       = true
    create_additonal_ebs_block_device = false
    root_block_device = {
      type                  = "gp3"
      size                  = 30
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options = {
    http_tokens = "required"
  }

  user_data = <<END
    #!/bin/bash
    cd ~
    wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
    tar xvzf node_exporter-1.8.2.linux-amd64.tar.gz
  END
}

############################################################
# EBS
############################################################
# resource "aws_ebs_volume" "this_tmp" {
#   count = var.create_tmp_ebs_resource ? 1 : 0

#   availability_zone = var.availability_zone

#   size       = var.ebs_size
#   type       = var.ebs_type
#   iops       = var.ebs_iops
#   throughput = var.ebs_throughput
#   encrypted  = var.ebs_encrypted

#   tags = {
#     Name = "ec2-bastion-${var.env}-tmp"
#   }
# }

# resource "aws_volume_attachment" "this_tmp" {
#   count = var.create_tmp_ebs_resource ? 1 : 0

#   device_name = var.ebs_device_name
#   volume_id   = aws_ebs_volume.this_tmp[0].id
#   instance_id = aws_instance.this.id
# }

############################################################
# IAM Role
############################################################
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
  name               = "ssm-ec2"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_instance_profile" "this" {
  name = aws_iam_role.this.name
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_policy_attach" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "bastion_cloudwatch_policy_attach" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

############################################################
# CloudWatch Logs
############################################################
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ssmlogs/ec2"
  retention_in_days = 7
}

############################################################
# Session Manager
############################################################
resource "aws_ssm_document" "this" {
  name            = "SSM-SessionManagerRunShell-compute"
  document_type   = "Session"
  document_format = "JSON"

  content = <<END
    {
      "description":"Session Manager",
      "inputs":{
        "cloudWatchEncryptionEnabled":false,
        "cloudWatchLogGroupName":"/compute/ec2/public",
        "cloudWatchStreamingEnabled":true,
        "idleSessionTimeout":60,
        "maxSessionDuration":60
      },
      "schemaVersion":"1.0",
      "sessionType":"Standard_Stream"
    }
  END
}
