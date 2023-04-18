module "autostop" {
  source            = "./autostop"
  name              = "${var.name}-autostop"
  cluster_arn       = var.cluster_arn
  service_name      = aws_ecs_service.main.name
  target_group_arn  = aws_lb_target_group.main.arn
  listener_rule_arn = aws_lb_listener_rule.main.arn
}
