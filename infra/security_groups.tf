resource "aws_security_group" "ecs_codeserver_sg" {
  vpc_id = aws_vpc.ecs_codeserver_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-codeserver-sg"
  }
}


resource "aws_security_group" "ecs_codeserver_tasks_sg" {
  vpc_id = aws_vpc.ecs_codeserver_vpc.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_codeserver_sg.id] # your ALB SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}





