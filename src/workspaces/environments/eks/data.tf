data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "DevilOps"
    workspaces = {
      name = var.vpc_source
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}