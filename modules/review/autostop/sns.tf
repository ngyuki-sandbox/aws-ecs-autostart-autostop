resource "aws_sns_topic" "this" {
  name = var.name

  tags = {
    Name = var.name
    "ecs:cluster-arn"       = var.cluster_arn,
    "ecs:service-name"      = var.service_name,
    "elb:listener-rule-arn" = var.listener_rule_arn,
  }
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.this.arn
}
