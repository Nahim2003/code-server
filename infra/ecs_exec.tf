resource "aws_iam_role_policy" "ecs_exec_ssm_messages" {
  name = "ecs-exec-ssm-messages"
  role = aws_iam_role.ecs_codeserver_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource = "*"
      }
    ]
  })
}
