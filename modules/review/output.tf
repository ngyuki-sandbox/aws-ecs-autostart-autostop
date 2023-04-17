
output "service_name" {
  value = aws_ecs_service.main.name
}

output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}
