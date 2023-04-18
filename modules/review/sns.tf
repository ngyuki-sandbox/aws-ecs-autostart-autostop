resource "aws_sns_topic" "this" {
  name = var.name

  tags = {
    Name = var.name
    "ecs:cluster-arn"       = var.cluster_arn
    "ecs:service-name"      = aws_ecs_service.main.name
    "elb:listener-rule-arn" = aws_lb_listener_rule.main.arn
    "elb:listener-priority" = var.listener_priority

  }
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "lambda"
  endpoint  = var.lambda_function_arn
}

resource "aws_lambda_permission" "this" {
  statement_id  = var.name
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.this.arn
}
