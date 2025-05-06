

data "aws_availability_zones" "available" {}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "~> 5.0"
  name                 = var.env
  cidr                 = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  azs                  = local.azs
  private_subnets      = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]      # This will divide the 10.0.0.0/16 CIDR block into 16 subnets (2^(4) = 16), each with a /20 mask.
  public_subnets       = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 64)] # This will divide the 10.0.0.0/16 CIDR block into 256 subnets (2^(8) = 256), each with a /24 mask, starting at offset 32.
  intra_subnets        = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 80)] # This will divide the 10.0.0.0/16 CIDR block into 256 subnets (2^(8) = 256), each with a /24 mask, starting at offset 40.
  database_subnets     = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 96)] # This will divide the 10.0.0.0/16 CIDR block into 256 subnets (2^(8) = 256), each with a /24 mask, starting at offset 48.

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  create_igw = true
  tags       = local.tags
  vpc_tags   = local.tags

  intra_subnet_tags = merge(local.tags, {
    "Tier" = "ControlPlane"
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