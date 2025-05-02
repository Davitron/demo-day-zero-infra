module "vpc" {
  source   = "../../../modules/vpc"
  env      = var.env
  vpc_cidr = "10.0.0.0/16"
}



