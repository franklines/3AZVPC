variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_name" {
  default = "tfVPC"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "external_traffic" {
  default = "0.0.0.0/0"
}

variable "public_subnets" {
  type = "list"
  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "private_subnets" {
  type = "list"
  default = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
}

data "aws_availability_zones" "available" {
  state = "available"
}



