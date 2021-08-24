resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.public_id

  enable_deletion_protection = false

  tags = {
    Name = "alb"
  }
}

resource "aws_lb_target_group" "tg_app" {
  name     = "app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

locals {
  instances_ids = [
    aws_instance.node_1.id,
    aws_instance.node_2.id,
    aws_instance.node_3.id
  ]
}

resource "aws_lb_target_group_attachment" "tga_cluster" {
  count            = length(local.instances_ids)
  target_group_arn = aws_lb_target_group.tg_app.arn
  target_id        = local.instances_ids[count.index]
  port             = 80
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "null"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "app_listener_rule" {
  listener_arn = aws_lb_listener.app_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_app.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }

}
