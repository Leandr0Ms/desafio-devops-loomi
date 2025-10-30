variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "devops-desafio"
}

variable "app_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "my_ip_cidr" {
  type    = string
  default = "0.0.0.0/0" # altere depois para seu IP público + /32
}
