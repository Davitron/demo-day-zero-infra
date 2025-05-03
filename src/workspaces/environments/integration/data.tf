data "terraform_remote_state" "workspaces" {
  for_each = local.workspaces
  backend = "remote"

  config = {
    organization = "DevilOps"
    workspaces = {
      name = each.value
    }
  }
}

data "aws_eks_cluster" "clusters" {
  for_each = local.workspaces
  name  = data.terraform_remote_state.workspaces[each.key].outputs.cluster_name
}

data "aws_eks_cluster_auth" "clusters" {
  for_each = local.workspaces
  name  = data.terraform_remote_state.workspaces[each.key].outputs.cluster_name
}