resource "aws_vpc" "main_vpc" {
  cidr_block = "15.0.0.0/16"
  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "main_vpc_pvt_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "15.0.1.0/24"

  tags = {
    Name = "main_vpc_pvt_subnet"
  }
}

resource "aws_subnet" "main_vpc_pub_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "15.0.10.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "main_vpc_pub_subnet"
  }
}

resource "aws_internet_gateway" "main_vpc_ig" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Second vpc IG"
  }
}

resource "aws_route_table" "pub_subnet_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_vpc_ig.id
  }
  route {
    cidr_block = aws_vpc.main_vpc.cidr_block
    gateway_id = "local"
  }
}

resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = aws_vpc.main_vpc.default_route_table_id
  route {
    cidr_block = aws_vpc.main_vpc.cidr_block
    gateway_id = "local"
  }
  tags = {
    Name = "Main VPC Default route table"
  }
}

resource "aws_route_table_association" "public_table_association" {
  subnet_id = aws_subnet.main_vpc_pub_subnet.id
  route_table_id = aws_route_table.pub_subnet_rt.id
}

resource "aws_network_acl" "public_subnet_acl" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_network_acl_rule" "allow_all_outbound" {
  network_acl_id = aws_network_acl.public_subnet_acl.id
  egress      = "true"
  protocol    = "all"
  rule_number = "100"
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "allow_https" {
  network_acl_id = aws_network_acl.public_subnet_acl.id
  egress     = "false"
  protocol   = "tcp"
  rule_number    = "100"
  rule_action     = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 443
  to_port    = 443
}

resource "aws_network_acl_rule" "allow_http" {
  network_acl_id = aws_network_acl.public_subnet_acl.id
  egress     = "false"
  protocol   = "tcp"
  rule_number    = "200"
  rule_action     = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 80
  to_port    = 80
}

resource "aws_network_acl_rule" "allow_web_server" {
  network_acl_id = aws_network_acl.public_subnet_acl.id
  egress     = "false"
  protocol   = "tcp"
  rule_number    = "300"
  rule_action     = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 8080
  to_port    = 8080
}

resource "aws_network_acl_rule" "allow_epiphemeral" {
  network_acl_id = aws_network_acl.public_subnet_acl.id
  egress     = "false"
  protocol   = "tcp"
  rule_number    = "400"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 1024
  to_port    = 65535
}

resource "aws_network_acl_association" "public_subnet_acl_association" {
  network_acl_id = aws_network_acl.public_subnet_acl.id
  subnet_id      = aws_subnet.main_vpc_pub_subnet.id
}

resource "aws_security_group" "public_instance_sg" {
  name        = "public_instance_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_server_ipv4" {
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}