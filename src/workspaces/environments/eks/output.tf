output "account_id" {
  description = "AWS account ID."
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS region."
  value       = data.aws_region.current.name
}

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

output "karpenter_iam_role" {
  description = "IAM role for Karpenter."
  value       = module.cluster.karpenter_iam_role
}

output "argocd_access_role" {
  description = "IAM role for ArgoCD."
  value       = var.cluster_mode == "workload" ? module.argocd_access_iam[0].iam_role_arn : null
}

output "registered_environments" {
  description = "Registered environments."
  value       = local.registered_environments
}

output "crossplane_iam_role" {
  description = "IAM role for Crossplane."
  value       = module.crossplane_iam.iam_role_arn
}

output "certmanager_iam_role" {
  description = "IAM role for Cert Manager."
  value       = module.certmanager.iam_role_arn
}


output "external_dns_iam_role" {
  description = "IAM role for External DNS."
  value       = module.external_dns.iam_role_arn
}

output "vault_iam_role" {

  description = "IAM role for Vault."
  value       = var.cluster_mode == "management" ? module.vault[0].iam_role_arn : null
}