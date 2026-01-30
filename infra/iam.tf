resource "aws_iam_role" "ecs_codeserver_task_execution_role" {
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

resource "aws_iam_role_policy_attachment" "ecs_codeserver_task_execution_role" {
  role       = aws_iam_role.ecs_codeserver_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
