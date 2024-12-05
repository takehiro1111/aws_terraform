############################################################
# EC2 Instance
############################################################
resource "aws_instance" "this" {
  ami                         = var.ec2_instance.ami
  subnet_id                   = var.ec2_instance.subnet_id
  instance_type               = var.ec2_instance.instance_type
  vpc_security_group_ids      = var.ec2_instance.vpc_security_group_ids
  iam_instance_profile        = var.ec2_instance.iam_instance_profile
  associate_public_ip_address = var.ec2_instance.associate_public_ip_address
  user_data                   = var.user_data

  root_block_device {
    volume_type           = var.ec2_instance.root_block_device.type
    volume_size           = var.ec2_instance.root_block_device.size
    delete_on_termination = var.ec2_instance.root_block_device.delete_on_termination
    encrypted             = var.ec2_instance.root_block_device.encrypted

    tags = {
      Name = "${var.ec2_instance.inastance_name}"
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ec2_instance.create_additonal_ebs_block_device ? [1] : []

    content {
      device_name           = var.ec2_instance.inastance_name
      volume_type           = var.ec2_instance.ebs_block_device.type
      volume_size           = var.ec2_instance.ebs_block_device.volume_size
      delete_on_termination = var.ec2_instance.ebs_block_device.delete_on_termination
      encrypted             = var.ec2_instance.ebs_block_device.encrypted
    }
  }

  metadata_options {
    http_tokens = var.metadata_options.http_tokens
  }

  tags = {
    Name = var.ec2_instance.inastance_name
  }

  lifecycle {
    ignore_changes = [associate_public_ip_address, user_data]
  }
}

############################################################
# EC2 State
############################################################
resource "aws_ec2_instance_state" "this" {
  instance_id = aws_instance.this.id
  state       = var.ec2_instance.state
}
