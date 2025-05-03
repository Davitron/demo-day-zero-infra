locals {
    workspaces = {
        "mgnt" = "management-eks"
    }

    cluster_data = {
        for k, v in local.workspaces :
        k => {
            cluster_name = data.terraform_remote_state.workspaces[k].outputs.cluster_name
            cluster_endpoint = data.terraform_remote_state.workspaces[k].outputs.cluster_endpoint
            cluster_certificate_authority_data = data.aws_eks_cluster.clusters[k].certificate_authority[0].data
            cluster_mode = data.terraform_remote_state.workspaces[k].outputs.cluster_mode
            argocd_access_role = lookup(data.terraform_remote_state.workspaces[k].outputs, "argocd_access_role", "")
        } if data.terraform_remote_state.workspaces[k].outputs.cluster_mode == "workload"
    }
}

output "cluster_data" {
  value = local.cluster_data
  
}