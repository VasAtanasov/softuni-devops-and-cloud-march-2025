provider "aws" {
  access_key = "<ACCESS-KEY>"
  secret_key = "<SECRET-KEY>"
  region     = "eu-central-1"
}

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
  cidr_block              = "10.10.10.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "DO1-SUB-NET"
  }
}

resource "aws_route_table_association" "do1-prt-assoc" {
  subnet_id      = aws_subnet.do1-snet.id
  route_table_id = aws_route_table.do1-prt.id
}

resource "aws_security_group" "do1-pub-sg" {
  name        = "do1-pub-sg"
  description = "DO1 Public SG"
  vpc_id      = aws_vpc.do1-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "do1-server" {
  ami                    = "ami-0229b8f55e5178b65"
  instance_type          = "t2.micro"
  key_name               = "terraform-key"
  vpc_security_group_ids = [aws_security_group.do1-pub-sg.id]
  subnet_id              = aws_subnet.do1-snet.id
}

output "public_ip" {
  value = aws_instance.do1-server.public_ip
}
