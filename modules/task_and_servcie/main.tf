module "ecs_alb_service_task" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "0.66.4"

  name         = "${var.ecs_cluster.name}-service"
  launch_type  = var.ecs_service.launch_type
  task_cpu     = var.ecs_service.task_cpu
  task_memory  = var.ecs_service.task_memory
  exec_enabled = true

  vpc_id           = var.vpc_id
  subnet_ids       = var.private_subnets
  network_mode     = var.ecs_service.network_mode
  assign_public_ip = var.ecs_service.assign_public_ip

  alb_security_group     = var.security_group_id
  enable_all_egress_rule = true
  use_alb_security_group = true
  container_port         = var.container_definition.port_mappings[0].containerPort

  container_definition_json = var.container_definition_json
  ecs_cluster_arn           = var.ecs_cluster_arn

  desired_count                  = var.ecs_service.desired_count
  ignore_changes_task_definition = var.ecs_service.ignore_changes_task_definition
  # task_exec_policy_arns          = [aws_iam_policy.policy.arn]
  # task_policy_arns               = [aws_iam_policy.policy.arn]


  health_check_grace_period_seconds  = var.ecs_service.health_check_grace_period_seconds
  deployment_minimum_healthy_percent = var.ecs_service.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.ecs_service.deployment_maximum_percent

  ecs_load_balancers = [
    {
      container_name   = "${var.ecs_cluster.name}-container"
      container_port   = var.container_definition.port_mappings[0].containerPort
      target_group_arn = var.target_group_arn
      elb_name         = ""
    }
  ]

  efs_volumes = [{
    name      = "nexus"
    host_path = null
    efs_volume_configuration = [{
      file_system_id          = var.efs_id
      root_directory          = "/opt"
      transit_encryption      = "ENABLED"
      transit_encryption_port = null
      authorization_config = [{
        access_point_id = var.efs_access_point
        iam             = "ENABLED"
      }]
    }]

  }]

  tags = var.shared_tags
}

resource "aws_iam_policy" "policy" {
  name = "${var.ecs_cluster.name}-policy"
  path = "/"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "efs:*",
          "ecr:*",
          "ec2:DescribeTags",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTelemetrySession",
          "ecs:UpdateContainerInstancesState",
          "ecs:Submit*",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "application-autoscaling:*",
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:ExecuteCommand",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DisableAlarmActions",
          "cloudwatch:EnableAlarmActions",
          "iam:CreateServiceLinkedRole",
          "ecr:*",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : [
          "*",
        ]
      }
    ]
  })
}

module "ecs_cloudwatch_autoscaling" {
  source                = "cloudposse/ecs-cloudwatch-autoscaling/aws"
  version               = "0.7.2"
  name                  = "nexus-autoscaling"
  namespace             = "nexus"
  stage                 = "nexus"
  service_name          = module.ecs_alb_service_task.service_name
  cluster_name          = var.ecs_cluster_name
  min_capacity          = var.ecs_service.autoscaling_min_capacity
  max_capacity          = var.ecs_service.autoscaling_max_capacity
  scale_down_adjustment = var.ecs_service.autoscaling_scale_down_adjustment
  scale_down_cooldown   = var.ecs_service.autoscaling_scale_down_cooldown
  scale_up_adjustment   = var.ecs_service.autoscaling_scale_up_adjustment
  scale_up_cooldown     = var.ecs_service.autoscaling_scale_up_cooldown
}

resource "aws_cloudwatch_metric_alarm" "scale-up" {
  alarm_name          = "nexus-scale-up-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_service.cpu_threshold_to_scale_up_task

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = module.ecs_alb_service_task.service_name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [module.ecs_cloudwatch_autoscaling.scale_up_policy_arn]
}
resource "aws_cloudwatch_metric_alarm" "scale-down" {
  alarm_name          = "biopace-scale-down-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_service.cpu_threshold_to_scale_down_task

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = module.ecs_alb_service_task.service_name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [module.ecs_cloudwatch_autoscaling.scale_down_policy_arn]
}