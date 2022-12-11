resource "aws_security_group" "alb_sg" {
  description = "Mastodon load balancer"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_security_group_rule" "alb_sg_rule_ingress_http" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.alb_sg.id
#   description       = "Allow all inbound traffic on port 80"
# }

# resource "aws_security_group_rule" "alb_sg_rule_ingress_https" {
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.alb_sg.id
#   description       = "Allow all inbound traffic on port 443"
# }

resource "aws_lb" "alb" {
  name                       = "mastodon-lb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  drop_invalid_header_fields = true

  enable_deletion_protection = true
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.mastodon_cert.arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "404"
    }
  }

  lifecycle {
    ignore_changes = all
  }
}
