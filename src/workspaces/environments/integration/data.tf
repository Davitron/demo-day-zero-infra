data "terraform_remote_state" "management_eks" {
  backend = "remote"

  config = {
    organization = "DevilOps"
    workspaces = {
      name = "management-eks"
    }
  }
}

data "aws_eks_cluster" "management_cluster" {
  name  = data.terraform_remote_state.management_eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "management_cluster" {
  name  = data.terraform_remote_state.management_eks.outputs.cluster_name
}