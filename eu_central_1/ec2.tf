#===================================
# eu-central-1
#===================================
resource "aws_instance" "frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  ami                         = "ami-023432ac84225fefd"
  subnet_id                   = aws_subnet.public_a_frankfurt.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.frankfurt_ec2.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.frankfurt.key_name
  provider                    = aws.eu-central-1
  iam_instance_profile        = aws_iam_instance_profile.session_manager_frankfurt.name
  user_data                   = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y curl
                EOF

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    delete_on_termination = false
    encrypted             = true

    tags = {
      Name = "frankfurt"
    }
  }

  # IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1" // 値を設定したインスタンス内からのみ取得可能
    http_tokens                 = "required"
    instance_metadata_tags      = "enabled"
  }
}

resource "aws_key_pair" "frankfurt" {
  key_name   = "francfurt"
  public_key = file("./key_pair/hcl.pub")
  provider   = aws.eu-central-1
}

data "aws_ami" "amazon_linux_frankfurt" {
  most_recent = true //AMIを更新する際、OSの中の設定は引き継がれないのでコメントアウト
  provider    = aws.eu-central-1

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [local.aws_owner] # Amazonの所有者ID
}
