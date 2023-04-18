output "review_dns_name" {
  value = trimsuffix("test.${var.dns_name}", ".")
}
