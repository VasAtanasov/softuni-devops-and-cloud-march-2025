variable "region" {
  description = "AWS Region"
  default     = "eu-central-1"
}

variable "v-ami-image" {
  description = "AMI image"
  # Debian 12 (HVM), EBS General Purpose (SSD) Volume Type
  default = "ami-0ef32de3e8ab0640e"
}

variable "v-instance-type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "v-instance-key" {
  description = "Instance key"
  default     = "terraform-key"
}

variable "do1-cidr" {
  default = "10.10.10.0/24"
}
