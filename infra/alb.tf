resource "aws_lb" "codeserver_alb" {
  name               = "ecs-codeserver-alb"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.ecs_codeserver_subnet.id,
    aws_subnet.ecs_codeserver_subnet_2.id
  ]
  security_groups = [aws_security_group.ecs_codeserver_sg.id]
}

resource "aws_lb_target_group" "ecs_codeserver_tg" {
  name        = "ecs-codeserver-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecs_codeserver_vpc.id
  target_type = "ip"

  health_check {
    path    = "/login"
    matcher = "200-399"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.codeserver_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.ecs-codeserver-cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_codeserver_tg.arn
  }
}
