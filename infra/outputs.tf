output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.ecs-codeserver-vpc.id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = [aws_subnet.ecs-codeserver-subnet.id, aws_subnet.ecs-codeserver-subnet-2.id]
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.ecs-codeserver-rt.id
}