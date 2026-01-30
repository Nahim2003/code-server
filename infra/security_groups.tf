resource "aws_security_group" "ecs_codeserver_sg" {
  vpc_id = aws_vpc.ecs_codeserver_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-codeserver-sg"
  }
}

resource "aws_security_group" "ecs_codeserver_tasks_sg" {
  vpc_id = aws_vpc.ecs_codeserver_vpc.id

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
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

resource "aws_security_group_rule" "task_ingress_from_alb_8080" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ecs_codeserver_tasks_sg.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_codeserver_sg.id
}
