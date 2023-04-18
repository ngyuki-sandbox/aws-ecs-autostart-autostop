output "review_dns_name" {
  value = [for m in module.review : m.dns_name]
}
