output "lb_dns_name" {
  value = module.common.dns_name
}

output "review_dns_name" {
  value = trimsuffix("test.${var.dns_name}", ".")
}
