module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.0.0"

  zone_id = var.zone_id

  records = [
    {
      name = var.record_name
      type = "A"
      alias = {
        name    = var.alias_dns_name
        zone_id = var.alias_zone_id
      }
    }
  ]
}