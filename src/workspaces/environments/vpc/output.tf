output "vpc_id" {
  value = module.vpc.id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  value = module.vpc.public_subnet
}

output "private_subnets" {
  value = module.vpc.private_subnet
}

output "intra_subnets" {
  value = module.vpc.intra_subnet
}
