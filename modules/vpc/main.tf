# list of available zones per region
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.12.0"

  name = var.vpc.name
  cidr = var.vpc.cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.vpc.private_subnets
  public_subnets  = var.vpc.public_subnets

  enable_nat_gateway = var.vpc.enable_nat_gateway
  single_nat_gateway = var.vpc.single_nat_gateway

  enable_dns_hostnames = var.vpc.enable_dns_hostnames
  enable_dns_support   = var.vpc.enable_dns_support

  tags = var.shared_tags
}
