module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
  az_1                 = var.az_1
  az_2                 = var.az_2
}

module "alb" {
  source = "./modules/alb"

  vpc_id             = module.vpc.vpc_id
  public_subnet_1_id = module.vpc.public_subnet_1_id
  public_subnet_2_id = module.vpc.public_subnet_2_id
  certificate_arn    = aws_acm_certificate_validation.ecs_codeserver.certificate_arn
}

module "ecs" {
  source = "./modules/ecs"

  vpc_id             = module.vpc.vpc_id
  public_subnet_1_id = module.vpc.public_subnet_1_id
  public_subnet_2_id = module.vpc.public_subnet_2_id
  alb_sg_id          = module.alb.alb_sg_id
  target_group_arn   = module.alb.target_group_arn

  image_uri          = var.image_uri
  execution_role_arn = aws_iam_role.ecs_codeserver_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_codeserver_task_execution_role.arn
  password           = var.password
  log_group_name     = var.log_group_name
  aws_region         = var.aws_region
}