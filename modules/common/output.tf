output "cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "execution_role_arn" {
  value = aws_iam_role.execution.arn
}

output "listener_arn" {
  value = aws_lb_listener.main.arn
}

output "dns_name" {
  value = aws_lb.main.dns_name
}
