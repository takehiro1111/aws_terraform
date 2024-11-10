#################################################################################
# Web Server
################################################################################
resource "aws_instance" "web_server" {
  count = var.create_web_server ? 1 : 0

  ami                         = "ami-027a31eff54f1fe4c" // 「Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type」のAMI
  subnet_id                   = data.terraform_remote_state.development_network.outputs.private_subnets_id_development
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

#################################################################################
# Prometheus Server
################################################################################
# module "prometheus_server" {
#   source = "../modules/ec2/general_instance"

#   env                  = local.env
#   vpc_id               = module.vpc_common.vpc_id
#   subnet_id            = aws_subnet.common["public_a"].id // NAT GWはを出来る限り有効化したくないため。
#   iam_instance_profile = aws_iam_instance_profile.session_manager.name

#   root_volume_name = "prometheus-server"
#   inastance_name   = "prometheus-server"

#   ## SessionManagerの設定は既に作成済みのためfalse
#   create_common_resource = false

#   ## 一時的にルートボリューム以外のEBSを作成する場合はtrueにする
#   create_tmp_ebs_resource = false

#   sg_name = "security-bastion"
# }

/*
 * Node Exporter用 
 */
# module "node_exporter" {
#   source = "../modules/ec2/general_instance"

#   env                  = "stg"
#   vpc_id               = module.vpc_common.vpc_id
#   subnet_id            = aws_subnet.common["public_a"].id // NAT GWはを出来る限り有効化したくないため。
#   iam_instance_profile = aws_iam_instance_profile.session_manager.name

#   root_volume_name = "node-exporter"
#   inastance_name   = "node-exporter"

#   ## SessionManagerの設定は既に作成済みのためfalse
#   create_common_resource = false

#   ## 一時的にルートボリューム以外のEBSを作成する場合はtrueにする
#   create_tmp_ebs_resource = false

#   sg_name = "prometheus-node-exporter"
# }
