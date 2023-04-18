resource "aws_ssm_parameter" "main" {
  name = "${var.parameter_prefix}/${var.dns_name}"
  type = "String"
  value = jsonencode({
    cluster_arn       = var.cluster_arn
    service_name      = aws_ecs_service.main.name
    listener_rule_arn = aws_lb_listener_rule.main.arn
    listener_priority = var.listener_priority
  })
}
