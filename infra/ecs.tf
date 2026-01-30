resource "aws_ecs_cluster" "ecs_codeserver_tf_cluster" {
  name = "ecs-codeserver-tf-cluster"
}

resource "aws_ecs_service" "ecs_codeserver_tf_service" {
  name            = "ecs-codeserver-tf-service"
  cluster         = aws_ecs_cluster.ecs_codeserver_tf_cluster.id
  task_definition = aws_ecs_task_definition.ecs_codeserver_tf_task.arn
  desired_count   = 1

  launch_type = "FARGATE"

   health_check_grace_period_seconds = 90

  network_configuration {
    subnets = [
      aws_subnet.ecs_codeserver_subnet.id,
      aws_subnet.ecs_codeserver_subnet_2.id
    ]

    security_groups  = [aws_security_group.ecs_codeserver_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_codeserver_tg.arn
    container_name   = "codeserver"
    container_port   = 8080
  }
}


resource "aws_ecs_task_definition" "ecs_codeserver_tf_task" {
  family                   = "ecs-codeserver-tf-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecs_codeserver_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_codeserver_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "codeserver"
      image     = "764283926008.dkr.ecr.us-east-1.amazonaws.com/ecs-codeserver:v12"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "PASSWORD", value = "Nahimahmed2003" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/ecs-codeserver-task"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
