resource "aws_vpc" "ecs-codeserver-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ecs-codeserver-vpc"
  }
}

resource "aws_subnet" "ecs-codeserver-subnet" {
  vpc_id                  = aws_vpc.ecs-codeserver-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-codeserver-subnet"
  }
}

resource "aws_subnet" "ecs-codeserver-subnet-2" {
  vpc_id                  = aws_vpc.ecs-codeserver-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-codeserver-subnet-2"
  }
}

resource "aws_internet_gateway" "ecs-codeserver-igw" {
  vpc_id = aws_vpc.ecs-codeserver-vpc.id

  tags = {
    Name = "ecs-codeserver-igw"
  }
}

resource "aws_route_table" "ecs-codeserver-rt" {
  vpc_id = aws_vpc.ecs-codeserver-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs-codeserver-igw.id
  }
}
resource "aws_route_table_association" "ecs-codeserver-rt-assoc" {
  subnet_id      = aws_subnet.ecs-codeserver-subnet.id
  route_table_id = aws_route_table.ecs-codeserver-rt.id
}

resource "aws_route_table_association" "ecs-codeserver-rt-assoc-2" {
  subnet_id      = aws_subnet.ecs-codeserver-subnet-2.id
  route_table_id = aws_route_table.ecs-codeserver-rt.id
}

resource "aws_security_group" "ecs-codeserver-sg" {
  vpc_id = aws_vpc.ecs-codeserver-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-codeserver-sg"
  }
}

resource "aws_security_group" "ecs-codeserver-tasks-sg" {
  vpc_id = aws_vpc.ecs-codeserver-vpc.id

  ingress {
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs-codeserver-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-codeserver-tasks-sg"
  }
}

resource "aws_lb" "ecs-codeserver-tf-alb" {
  name               = "ecs-codeserver-tf-alb"
  internal           = false
  security_groups    = [aws_security_group.ecs-codeserver-sg.id]
  subnets            = [aws_subnet.ecs-codeserver-subnet.id, aws_subnet.ecs-codeserver-subnet-2.id]
  load_balancer_type = "application"
  tags = {
    Name = "ecs-codeserver-tf-alb"
  }
}

resource "aws_lb_target_group" "ecs-codeserver-tf-alb-tg" {
  name        = "ecs-codeserver-tf-alb-tg"
  vpc_id      = aws_vpc.ecs-codeserver-vpc.id
  port        = 3001
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_iam_role" "ecs-codeserver-task-execution-role" {
  name = "ecs-codeserver-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ecs-codeserver-task-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs-codeserver-task-execution-role" {
  role       = aws_iam_role.ecs-codeserver-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ecs-codeserver-tf-task" {
  family                   = "ecs-codeserver-tf-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs-codeserver-task-execution-role.arn
  task_role_arn            = aws_iam_role.ecs-codeserver-task-execution-role.arn

  container_definitions = jsonencode([
    {
      name      = "codeserver"
      image     = "764283926008.dkr.ecr.us-east-1.amazonaws.com/ecs-codeserver:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3001
          protocol      = "tcp"
        }
      ]
      command = ["/app/start.sh"]

      logconfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/ecs-codeserver-task"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"

          health_check_path = "/health"
        }
      }
    }
  ])
}
resource "aws_ecs_service" "ecs-codeserver-tf-service" {
  name            = "ecs-codeserver-tf-service"
  cluster         = aws_ecs_cluster.ecs-codeserver-tf-cluster.id
  task_definition = aws_ecs_task_definition.ecs-codeserver-tf-task.arn
  launch_type     = "FARGATE"
  desired_count   = 1


  network_configuration {
    subnets          = [aws_subnet.ecs-codeserver-subnet.id, aws_subnet.ecs-codeserver-subnet-2.id]
    security_groups  = [aws_security_group.ecs-codeserver-sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-codeserver-tf-alb-tg.arn
    container_name   = "codeserver"
    container_port   = 3001
  }
}

resource "aws_ecs_cluster" "ecs-codeserver-tf-cluster" {
  name = "ecs-codeserver-tf-cluster"
}

resource "aws_lb_listener" "ecs-codeserver-tf-alb-listener" {
  load_balancer_arn = aws_lb.ecs-codeserver-tf-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-codeserver-tf-alb-tg.arn
  }
}