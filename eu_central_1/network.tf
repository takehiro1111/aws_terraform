# VPC -------------------------------------
resource "aws_vpc" "frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  cidr_block           = module.value.vpc_ip["hcl"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  provider             = aws.eu-central-1
}

# #Public Subnet------------------------------
resource "aws_subnet" "public_a_frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  vpc_id                  = aws_vpc.frankfurt.id
  cidr_block              = module.value.hashicorp_subnet_ip["a_public"]
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false
  provider                = aws.eu-central-1

  tags = {
    "Name" = "public-sn-1"
  }
}

# # IGW -------------------------------------
resource "aws_internet_gateway" "frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  vpc_id   = aws_vpc.frankfurt.id
  provider = aws.eu-central-1
}

resource "aws_eip" "frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  domain   = "vpc"
  provider = aws.eu-central-1

  depends_on = [
    aws_internet_gateway.frankfurt
  ]
}

resource "aws_eip_association" "frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  instance_id   = aws_instance.sense_share.id
  allocation_id = aws_eip.frankfurt.id
  provider      = aws.eu-central-1
}

# # Route Table --------------------------------
resource "aws_route_table" "frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  vpc_id   = aws_vpc.frankfurt.id
  provider = aws.eu-central-1

  depends_on = [aws_vpc.frankfurt]

  tags = {
    "Name" = "public-rtb"
  }
}

resource "aws_route" "frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  route_table_id         = aws_route_table.frankfurt.id
  destination_cidr_block = module.value.gateway
  gateway_id             = aws_internet_gateway.frankfurt.id
  provider               = aws.eu-central-1
}

resource "aws_route_table_association" "public_a_frankfurt" {
  count = var.eu_central_1 ? 1 : 0

  subnet_id      = aws_subnet.public_a_frankfurt.id
  route_table_id = aws_route_table.frankfurt.id
  provider       = aws.eu-central-1
}
