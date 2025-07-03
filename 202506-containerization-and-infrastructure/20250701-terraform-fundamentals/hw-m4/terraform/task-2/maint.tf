terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "do1-web" {
  ami           = var.v-ami-image
  instance_type = var.v-instance-type
  key_name      = var.v-instance-key

  tags = {
    Name = "bgapp-web"
  }

  network_interface {
    network_interface_id = aws_network_interface.do1-web-net.id
    device_index         = 0
  }

}

resource "aws_instance" "do1-db" {
  ami           = var.v-ami-image
  instance_type = var.v-instance-type
  key_name      = var.v-instance-key

  tags = {
    Name = "bgapp-db"
  }

  network_interface {
    network_interface_id = aws_network_interface.do1-db-net.id
    device_index         = 0
  }

}