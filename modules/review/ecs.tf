resource "aws_ecs_task_definition" "main" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      "name" : "app",
      "image" : var.image,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 80,
          "protocol" : "tcp"
        }
      ],
    }
  ])
}

resource "aws_ecs_service" "main" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.main.arn
  launch_type     = "FARGATE"

  desired_count                      = 0
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "app"
    container_port   = 80
  }
}
