module "ecs_cluster" {
  source      = "./modules/ecs_cluster"
  ecs_cluster = var.ecs_cluster
  shared_tags = var.shared_tags
}

module "container_definition" {
  source               = "./modules/container_definition"
  ecs_cluster          = var.ecs_cluster
  aws_region           = var.aws_region
  image   = "sonatype/nexus3"
  container_definition = var.container_definition
  shared_tags          = var.shared_tags
}

module "task_and_service" {
  source                    = "./modules/task_and_servcie"
  ecs_cluster               = var.ecs_cluster
  ecs_service               = var.ecs_service
  vpc_id                    = var.vpc_id
  private_subnets           = var.subnets
  security_group_id         = module.alb.security_group_id
  container_definition      = var.container_definition
  container_definition_json = module.container_definition.container_definition_json
  ecs_cluster_arn           = module.ecs_cluster.ecs_cluster_arn
  ecs_cluster_name          = module.ecs_cluster.ecs_cluster_name
  target_group_arn          = module.alb.target_group_arn
  efs_id = module.efs.efs_id
  efs_access_point = module.efs.access_point
  shared_tags               = var.shared_tags
}

module "efs" {
  source = "./modules/efs"
  efs = var.efs
  shared_tags = var.shared_tags
  vpc_id = var.vpc_id
  subnet_id_1 = var.subnets[0]
  subnet_id_2 = var.subnets[1]
}


module "alb" {
  source              = "./modules/alb"
  alb                 = var.alb
  ecs_cluster         = var.ecs_cluster
  vpc_id              = var.vpc_id
  public_subnets      = var.subnets
  backend_port        = var.container_definition.port_mappings[0].containerPort
}

