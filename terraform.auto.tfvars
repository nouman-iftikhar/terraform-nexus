aws_region = "us-west-1"
vpc_id = "vpc-16978f73"
subnets = ["subnet-d271818a","subnet-dcda76b8"]
shared_tags = {
  project_name = "nexus"
  environment  = "dev"
  managed_by   = "Terraform"
}

ecs_cluster = {
  name                               = "nexus-ecs"
  container_insights                 = true
  capacity_providers                 = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy = [{ capacity_provider = "FARGATE" }]
}

alb = {
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  load_balancer_type  = "application"
  health_check = {
    path    = "/"
    matcher = "200-299"
  }

}

container_definition = {
  port_mappings = [
    {
      containerPort = 8081
      hostPort      = 8081
      protocol      = "tcp"
    }
  ]
}

ecs_service = {
  launch_type                        = "FARGATE"
  task_cpu                           = 1024
  task_memory                        = 6144
  network_mode                       = "awsvpc"
  desired_count                      = 1
  assign_public_ip                   = true
  ignore_changes_task_definition     = false
  health_check_grace_period_seconds  = 300
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  autoscaling_min_capacity           = 1
  autoscaling_max_capacity           = 1
  autoscaling_scale_down_adjustment  = -1
  autoscaling_scale_down_cooldown    = 300
  autoscaling_scale_up_adjustment    = 1
  autoscaling_scale_up_cooldown      = 60
  cpu_threshold_to_scale_up_task     = 80
  cpu_threshold_to_scale_down_task   = 20
}

efs = {
  name = "nexus-efs"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["2049-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  
}