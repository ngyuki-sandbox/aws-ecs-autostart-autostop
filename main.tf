module "vpc" {
  source = "./modules/vpc"
  name   = var.name
}

module "common" {
  source             = "./modules/common"
  name               = var.name
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.subnet_ids
  security_group_ids = [module.vpc.security_group_id]
}

module "autostart" {
  source       = "./modules/autostart"
  name         = "${var.name}-autostart"
  cluster_arn  = module.common.cluster_arn
  service_name = module.common.service_name
  listener_arn = module.common.listener_arn
  dns_name     = module.common.dns_name
}

module "autostop" {
  source                   = "./modules/autostop"
  name                     = "${var.name}-autostop"
  cluster_arn              = module.common.cluster_arn
  service_name             = module.common.service_name
  target_group_arn         = module.common.target_group_arn
  lambda_listener_rule_arn = module.autostart.lambda_listener_rule_arn
  lambda_role_arn          = module.autostart.lambda_role_arn
  lambda_filename          = module.autostart.lambda_filename
  lambda_filehash          = module.autostart.lambda_filehash
}
