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
  zone_name          = var.zone_name
  dns_name           = var.dns_name
  parameter_prefix   = "/${var.name}/review"
}

module "review" {
  source             = "./modules/review"
  name               = "${var.name}-review"
  dns_name           = trimsuffix("test.${var.dns_name}", ".")
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.subnet_ids
  security_group_ids = [module.vpc.security_group_id]
  listener_arn       = module.common.listener_arn
  execution_role_arn = module.common.execution_role_arn
  cluster_id         = module.common.cluster_id
  cluster_arn        = module.common.cluster_arn
  parameter_prefix   = "/${var.name}/review"
}
