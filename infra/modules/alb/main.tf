resource "aws_security_group" "alb" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-codeserver-alb-sg"
  }
}

resource "aws_lb" "this" {
  name               = "ecs-codeserver-alb"
  load_balancer_type = "application"
  idle_timeout       = 3600

  subnets = [
    var.public_subnet_1_id,
    var.public_subnet_2_id
  ]

  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "this" {
  name        = "ecs-codeserver-tg-8080"
  vpc_id      = var.vpc_id
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
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}