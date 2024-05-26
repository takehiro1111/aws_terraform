#=========================================
#EBSボリューム
#=========================================
resource "aws_ebs_volume" "this" {
  availability_zone = var.volume_az
  size              = var.volume_size
  encrypted         = var.volume_encrypted
  type              = "gp3"
  tags = {
    Name = var.volume_name
  }
}

resource "aws_volume_attachment" "this" {
  device_name                    = var.device_name
  volume_id                      = aws_ebs_volume.this.id
  instance_id                    = var.instance_id
  stop_instance_before_detaching = var.stop_instance_before_detaching
}
