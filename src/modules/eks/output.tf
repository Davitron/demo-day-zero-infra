output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_oidc_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "node_groups" {
  value = module.eks.eks_managed_node_groups
}


output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "karpenter_iam_role" {
  description = "IAM role for Karpenter."
  value       = module.karpenter.iam_role_arn
}

output "cluster_certificate_authority_data" {
  description = "Certificate for EKS control plane."
  value       = module.eks.cluster_certificate_authority_data
}
