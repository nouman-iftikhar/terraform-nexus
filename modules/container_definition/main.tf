module "cloudwatch_log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "2.4.1"

  name              = "${var.ecs_cluster.name}-log-group"
  retention_in_days = 7
}

module "container_definition" {
  source = "cloudposse/ecs-container-definition/aws"

  container_name  = "${var.ecs_cluster.name}-container"
  container_image = var.image

  log_configuration = {
    logDriver = "awslogs",
    options = {
      "awslogs-group"         = module.cloudwatch_log_group.cloudwatch_log_group_name,
      "awslogs-region"        = var.aws_region,
      "awslogs-stream-prefix" = "nexus"
    }

  }

  mount_points = [{
    containerPath = "/opt/sonatype/nexus-data"
    sourceVolume  = "nexus"
    readOnly      = false
  }]

  port_mappings = var.container_definition.port_mappings
  
}
