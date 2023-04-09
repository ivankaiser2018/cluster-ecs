#
# ECS ALB
#
# alb main definition

resource "aws_alb" "alb" {
  name            = var.ALB_NAME
  internal        = false
  load_balancer_type = var.ALB_TYPE
  security_groups = [aws_security_group.alb-sg.id]
  subnets   =  var.VPC_SUBNETS_ALB
  enable_deletion_protection = false
}


# Criar o Target Group do Load Balancer
resource "aws_alb_target_group" "target-lb-metabase" {
  name        = "target-lb-metabase"
  port        = 3000
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id      = var.VPC_ID
}



# alb listener (http)
resource "aws_alb_listener" "alb-http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.target-lb-metabase.arn
    type             = "forward"
  }
}



resource "aws_lb_listener_rule" "alb_rule" {
  listener_arn = aws_alb_listener.alb-http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target-lb-metabase.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

}
 




resource "aws_security_group" "alb-sg" {
  name        = var.ALB_NAME
  vpc_id      = var.VPC_ID
  description = var.ALB_NAME

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



