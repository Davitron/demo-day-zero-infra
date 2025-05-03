provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.workspaces["mgnt"].outputs.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.clusters["mgnt"].token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.clusters["mgnt"].certificate_authority[0].data)
  }
}

provider "kubectl" {
  host                   = data.terraform_remote_state.workspaces["mgnt"].outputs.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.clusters["mgnt"].token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.clusters["mgnt"].certificate_authority[0].data)
}