resource "aws_lb" "main" {
  name               = var.name
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "403 Forbidden"
      status_code  = "403"
    }
  }
}

resource "aws_lb_target_group" "lambda" {
  name        = "${var.name}-lambda"
  target_type = "lambda"

  tags = {
    Name = var.name
  }
}

resource "aws_lb_target_group_attachment" "lambda" {
  target_group_arn = aws_lb_target_group.lambda.arn
  target_id        = aws_lambda_function.main.arn
  depends_on       = [aws_lambda_permission.main]
}

resource "aws_lb_listener_rule" "lambda" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 10000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda.arn
  }

  condition {
    host_header {
      values = [trimsuffix("*.${var.dns_name}", ".")]
    }
  }
}
