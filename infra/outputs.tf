output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.ecs_codeserver_vpc.id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = [aws_subnet.ecs_codeserver_subnet.id, aws_subnet.ecs_codeserver_subnet_2.id]
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.ecs_codeserver_rt.id
}