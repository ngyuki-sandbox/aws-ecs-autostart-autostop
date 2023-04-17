resource "aws_lb_target_group" "this" {
  name        = "${var.prefix}-${substr(sha1(var.name), 0, 31 - length(var.prefix))}"
  target_type = "lambda"

  tags = {
    Name = var.name
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_lambda_function.this.arn
  depends_on       = [aws_lambda_permission.this]
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [var.dns_name]
    }
  }
}
