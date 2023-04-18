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
  source = "./modules/review"

  for_each = {
    nginx  = { priority = 1, image = "nginx:alpine" }
    apache = { priority = 2, image = "httpd:alpine" }
  }

  name              = "${var.name}-${each.key}"
  dns_name          = trimsuffix("${each.key}.${var.dns_name}", ".")
  image             = each.value.image
  listener_priority = each.value.priority

  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.subnet_ids
  security_group_ids   = [module.vpc.security_group_id]

  cluster_id           = module.common.cluster_id
  cluster_arn          = module.common.cluster_arn
  execution_role_arn   = module.common.execution_role_arn
  listener_arn         = module.common.listener_arn
  lambda_function_arn  = module.common.lambda_function_arn
  lambda_function_name = module.common.lambda_function_name
  parameter_prefix     = "/${var.name}/review"
}
