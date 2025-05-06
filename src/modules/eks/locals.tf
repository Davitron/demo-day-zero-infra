data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  cluster_name = var.env
  eks_odic_id  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")

  partition = data.aws_partition.current.partition
  region    = data.aws_region.current.name
  account   = data.aws_caller_identity.current.account_id

  tags = {
    Env     = var.env
    "Owner" = "The DevilOps"
  }
}