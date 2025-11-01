#######################################################
# EC2
#######################################################
resource "aws_instance" "web_api_server_1" {
  lifecycle {
    ignore_changes = [vpc_security_group_ids] # LocalStack では apply が差分が出続けるため
  }

  ami           = "hoge"
  instance_type = "t3.micro"
  // ラベル名変更予定
  subnet_id              = aws_subnet.public_1a[var.cidr_block.public_1a].id
  vpc_security_group_ids = [aws_security_group.web_api_server.id]
  iam_instance_profile   = aws_iam_instance_profile.web_api_server_profile.name

  tags = {
    Env           = "production"
    Configuration = "terraform"
    Name          = "production_web_api_server_1"
  }
}

resource "aws_instance" "web_api_server_2" {
  lifecycle {
    ignore_changes = [vpc_security_group_ids] # LocalStack では apply が差分が出続けるため
  }

  ami           = "hoge"
  instance_type = "t3.micro"
  // ラベル名変更予定
  subnet_id              = aws_subnet.public_1a[var.cidr_block.public_1a].id
  vpc_security_group_ids = [aws_security_group.web_api_server.id]
  iam_instance_profile   = aws_iam_instance_profile.web_api_server_profile.name

  tags = {
    Env           = "production"
    Configuration = "terraform"
    Name          = "production_web_api_server_2"
  }
}


resource "aws_instance" "job_worker_server_1" {
  lifecycle {
    ignore_changes = [vpc_security_group_ids] # LocalStack では apply が差分が出続けるため
  }

  ami           = "hoge"
  instance_type = "t3.micro"
  // ラベル名変更予定
  subnet_id                   = aws_subnet.public_1a[var.cidr_block.private_1a].id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.job_worker_server.id]
  iam_instance_profile        = aws_iam_instance_profile.job_worker_profile.name

  tags = {
    Env           = "production"
    Configuration = "terraform"
    Name          = "production_job_worker_server_1"
  }
}

resource "aws_instance" "job_worker_server_2" {
  lifecycle {
    ignore_changes = [vpc_security_group_ids] # LocalStack では apply が差分が出続けるため
  }

  ami                         = "hoge"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_1a[var.cidr_block.private_1a].id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.job_worker_server.id]
  iam_instance_profile        = aws_iam_instance_profile.job_worker_profile.name

  tags = {
    Env           = "production"
    Configuration = "terraform"
    Name          = "production_job_worker_server_2"
  }
}
