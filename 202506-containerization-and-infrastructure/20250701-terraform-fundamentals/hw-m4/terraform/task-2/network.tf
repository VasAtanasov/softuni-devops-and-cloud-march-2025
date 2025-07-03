resource "aws_vpc" "do1-vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "DO1-VPC"
  }
}

resource "aws_internet_gateway" "do1-igw" {
  vpc_id = aws_vpc.do1-vpc.id

  tags = {
    Name = "DO1-IGW"
  }
}

resource "aws_route_table" "do1-prt" {
  vpc_id = aws_vpc.do1-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.do1-igw.id
  }

  tags = {
    Name = "DO1-PUBLIC_RT"
  }
}

resource "aws_subnet" "do1-snet" {
  vpc_id                  = aws_vpc.do1-vpc.id
  cidr_block              = var.do1-cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "DO1-SUB-NET"
  }
}

resource "aws_route_table_association" "do1-prt-assoc" {
  subnet_id      = aws_subnet.do1-snet.id
  route_table_id = aws_route_table.do1-prt.id
}

resource "aws_network_interface" "do1-web-net" {
  subnet_id       = aws_subnet.do1-snet.id
  private_ips     = ["10.10.10.100"]
  security_groups = [aws_security_group.do1-pub-sg.id]

  tags = {
    Name = "DO1-WEB-PRIVATE-IP"
  }
}

resource "aws_network_interface" "do1-db-net" {
  subnet_id       = aws_subnet.do1-snet.id
  private_ips     = ["10.10.10.101"]
  security_groups = [aws_security_group.do1-pub-sg.id]

  tags = {
    Name = "DO1-DB-PRIVATE-IP"
  }
}