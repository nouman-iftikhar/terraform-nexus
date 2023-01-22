module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.8.0"


  name        = "${var.ecs_cluster.name}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id


  ingress_cidr_blocks = var.alb.ingress_cidr_blocks
  ingress_rules       = var.alb.ingress_rules


  egress_cidr_blocks = var.alb.egress_cidr_blocks
  egress_rules       = var.alb.egress_rules
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"


  name               = "${var.ecs_cluster.name}-alb"
  load_balancer_type = var.alb.load_balancer_type
  vpc_id             = var.vpc_id
  subnets            = var.public_subnets
  security_groups    = [module.alb_sg.security_group_id]


  target_groups = [
    {
      name                 = "tg-nexus"
      backend_port         = var.backend_port
      backend_protocol     = "HTTP"
      target_type          = "ip"
      health_check         = var.alb.health_check
      deregistration_delay = 120
      targets              = []
    }
  ]

    http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}