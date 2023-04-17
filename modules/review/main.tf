
module "autostart" {
  source       = "./autostart"
  name         = "${var.name}-autostart"
  prefix       = var.name
  dns_name     = var.dns_name
  cluster_arn  = var.cluster_arn
  listener_arn = var.listener_arn
  service_name = aws_ecs_service.main.name
}

module "autostop" {
  source                   = "./autostop"
  name                     = "${var.name}-autostop"
  cluster_arn              = var.cluster_arn
  service_name             = aws_ecs_service.main.name
  target_group_arn         = aws_lb_target_group.main.arn
  lambda_listener_rule_arn = module.autostart.lambda_listener_rule_arn
  lambda_role_arn          = module.autostart.lambda_role_arn
  lambda_filename          = module.autostart.lambda_filename
  lambda_filehash          = module.autostart.lambda_filehash
}
