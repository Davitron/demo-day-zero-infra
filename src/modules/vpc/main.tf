

data "aws_availability_zones" "available" {}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "~> 5.0"
  name                 = var.env
  cidr                 = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  azs                  = local.azs
  private_subnets      = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets       = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 32)]
  intra_subnets        = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 40)]
  database_subnets     = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  create_igw = true

  tags     = local.tags
  vpc_tags = local.tags

  intra_subnet_tags = merge(local.tags, {
    "cast.ai/routable"                 = true
  })
  
  public_subnet_tags = merge(local.tags, {
    "kubernetes.io/role/elb" = 1
  })

  private_subnet_tags = merge(local.tags, {
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = true
  })

  database_subnet_tags = merge(local.tags, {
    tier = "Database"
  })
}