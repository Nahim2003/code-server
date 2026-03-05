resource "aws_lb" "codeserver_alb" {
  name               = "ecs-codeserver-alb"
  load_balancer_type = "application"
  idle_timeout       = 3600

  subnets = [
    aws_subnet.ecs_codeserver_subnet.id,
    aws_subnet.ecs_codeserver_subnet_2.id
  ]

  security_groups = [aws_security_group.ecs_codeserver_sg.id]
}

# NEW target group for direct code-server (8080)
resource "aws_lb_target_group" "ecs_codeserver_tg_8080" {
  name        = "ecs-codeserver-tg-8080"
  vpc_id      = aws_vpc.ecs_codeserver_vpc.id
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"

  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

  health_check {
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/login"
    matcher             = "200-399"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.codeserver_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
  certificate_arn   = aws_acm_certificate.ecs_codeserver_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_codeserver_tg_8080.arn
  }
}
