resource "aws_vpc" "ecs_codeserver_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ecs-codeserver-vpc"
  }
}

resource "aws_subnet" "ecs_codeserver_subnet" {
  vpc_id                  = aws_vpc.ecs_codeserver_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-codeserver-subnet"
  }
}

resource "aws_subnet" "ecs_codeserver_subnet_2" {
  vpc_id                  = aws_vpc.ecs_codeserver_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-codeserver-subnet-2"
  }
}

resource "aws_internet_gateway" "ecs_codeserver_igw" {
  vpc_id = aws_vpc.ecs_codeserver_vpc.id

  tags = {
    Name = "ecs-codeserver-igw"
  }
}

resource "aws_route_table" "ecs_codeserver_rt" {
  vpc_id = aws_vpc.ecs_codeserver_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_codeserver_igw.id
  }
}
resource "aws_route_table_association" "ecs_codeserver_rt_assoc" {
  subnet_id      = aws_subnet.ecs_codeserver_subnet.id
  route_table_id = aws_route_table.ecs_codeserver_rt.id
}

resource "aws_route_table_association" "ecs_codeserver_rt_assoc_2" {
  subnet_id      = aws_subnet.ecs_codeserver_subnet_2.id
  route_table_id = aws_route_table.ecs_codeserver_rt.id
}
