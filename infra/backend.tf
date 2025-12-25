terraform {
  backend "s3" {
    bucket = "ecs-codeserver-tf-state-nahim"
    region = "us-east-1"
    key    = "ecs-codeserver/terraform.tfstate"
  }
}