output "cluster_id" {
  value = module.cluster.cluster_id
}

output "cluster_name" {
  value = module.cluster.cluster_name
}

output "cluster_oidc_url" {
  value = module.cluster.cluster_oidc_url
}

output "oidc_provider_arn" {
  value = module.cluster.oidc_provider_arn
}

# # output "cluster_endpoint" {
# #   value = module.cluster.cluster_endpoint
# # }

# output "cluster_certificate" {
#   description = "Certificate for EKS control plane."
#   value       = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
# }

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.cluster.cluster_endpoint
}

output "cluster_mode" {
  description = "Cluster mode (management or workload)."
  value       = var.cluster_mode
}

# output "cluster_token" {
#   description = "Token for EKS control plane."
#   value       = data.aws_eks_cluster_auth.cluster.token
# }

output "karpenter_iam_role" {
  description = "IAM role for Karpenter."
  value       = module.cluster.karpenter_iam_role
}

output "argocd_access_role" {
  description = "IAM role for ArgoCD."
  value       = var.cluster_mode == "workload" ? module.argocd_access_iam[0].iam_role_arn : null
}