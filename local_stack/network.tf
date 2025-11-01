resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"


}

resource "aws_subnet" "public_1a" {
  for_each = toset([
    var.cidr_block.public_1a,
    var.cidr_block.private_1a
  ])
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.key
  availability_zone = "ap-northeast-1a"
}

# resource "aws_subnet" "private_1a" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = 
#   availability_zone = "ap-northeast-1a"

#   tags = {
#     Env           = "production"
#     Configuration = "terraform"
#   }
# }

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat_gateway_1a" {
  domain = "vpc"
}

resource "aws_eip" "web_api_server_1" {
  instance = aws_instance.web_api_server_1.id
  domain   = "vpc"
}

resource "aws_eip" "web_api_server_2" {
  instance = aws_instance.web_api_server_2.id
  domain   = "vpc"
}

resource "aws_route_table" "public_1a" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_1a" {
  route_table_id         = aws_route_table.public_1a.id
  destination_cidr_block = var.cidr_block.public_1a
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a[var.cidr_block.public_1a].id
  route_table_id = aws_route_table.public_1a.id
}

resource "aws_nat_gateway" "public_1a" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.nat_gateway_1a.id
  subnet_id     = aws_subnet.public_1a[var.cidr_block.public_1a].id
}

resource "aws_route_table" "private_1a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = var.cidr_block.private_1a
    nat_gateway_id = aws_nat_gateway.public_1a.id
  }

}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_1a.id
}




resource "aws_route53_zone" "main" {
  name = "example.com"
}

resource "aws_route53_record" "web_api_server_1" {
  zone_id                          = aws_route53_zone.main.zone_id
  name                             = "www.example.com"
  type                             = "A"
  ttl                              = 300
  records                          = [aws_eip.web_api_server_1.public_ip]
  multivalue_answer_routing_policy = true
  set_identifier                   = "web_api_server_1"
}

resource "aws_route53_record" "web_api_server_2" {
  zone_id                          = aws_route53_zone.main.zone_id
  name                             = "www.example.com"
  type                             = "A"
  ttl                              = 300
  records                          = [aws_eip.web_api_server_2.public_ip]
  multivalue_answer_routing_policy = true
  set_identifier                   = "web_api_server_2"
}
