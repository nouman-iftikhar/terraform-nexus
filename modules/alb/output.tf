output "security_group_id" {
  value = module.alb_sg.security_group_id
}
output "target_group_arn" {
  value = module.alb.target_group_arns[0]
}

output "alb_dns_name" {
  value = module.alb.lb_dns_name
}

output "alb_zone_id" {
  value = module.alb.lb_zone_id
}