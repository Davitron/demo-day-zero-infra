output "cluster_id" {
  value = module.control-cluster.cluster_id
}

output "cluster_name" {
  value = module.control-cluster.cluster_name
}

output "cluster_oidc_url" {
  value = module.control-cluster.cluster_oidc_url
}

output "oidc_provider_arn" {
  value = module.control-cluster.oidc_provider_arn
}

# # output "cluster_endpoint" {
# #   value = module.control-cluster.cluster_endpoint
# # }

# output "cluster_certificate" {
#   description = "Certificate for EKS control plane."
#   value       = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
# }

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.control-cluster.cluster_endpoint
}

# output "cluster_token" {
#   description = "Token for EKS control plane."
#   value       = data.aws_eks_cluster_auth.cluster.token
# }

output "karpenter_iam_role" {
  description = "IAM role for Karpenter."
  value       = module.control-cluster.karpenter_iam_role
}