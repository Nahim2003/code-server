output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  value = [
    module.vpc.public_subnet_1_id,
    module.vpc.public_subnet_2_id
  ]
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}