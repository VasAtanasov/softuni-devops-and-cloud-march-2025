terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

resource "aws_instance" "vm1" {
  ami           = "ami-0229b8f55e5178b65"
  instance_type = "t2.micro"
  key_name      = "terraform-key"

  tags = {
    Name = "terraform-example"
  }
}

output "public_ip" {
  value = aws_instance.vm1.public_ip
}

output "public_dns" {
  value = aws_instance.vm1.public_dns
}