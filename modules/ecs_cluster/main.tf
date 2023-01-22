module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "3.5.0"

  name                               = "${var.ecs_cluster.name}-cluster"
  container_insights                 = var.ecs_cluster.container_insights
  capacity_providers                 = var.ecs_cluster.capacity_providers
  default_capacity_provider_strategy = var.ecs_cluster.default_capacity_provider_strategy

  tags = var.shared_tags
}