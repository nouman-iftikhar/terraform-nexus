module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = var.domain_name
  zone_id     = var.zone_id

  subject_alternative_names = [
    var.subject_alternative_names
  ]

  wait_for_validation = true

  tags = var.shared_tags
}