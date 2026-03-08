variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "az_1" {
  type    = string
  default = "us-east-1a"
}

variable "az_2" {
  type    = string
  default = "us-east-1b"
}

variable "image_uri" {
  type    = string
  default = "764283926008.dkr.ecr.us-east-1.amazonaws.com/ecs-codeserver:v18"
}

variable "password" {
  type      = string
  sensitive = true
  default   = "Nahimahmed2003"
}

variable "log_group_name" {
  type    = string
  default = "/ecs/ecs-codeserver-task"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}