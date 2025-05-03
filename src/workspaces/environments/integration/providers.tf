provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.management_eks.outputs.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.management_cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.management_cluster.certificate_authority.0.data)
  }
}

provider "kubectl" {
  host                   = data.terraform_remote_state.management_eks.outputs.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.management_cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.management_cluster.certificate_authority.0.data)
}