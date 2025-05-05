locals {
  registered_environments = {
    "mgnt" = "management-eks"
    "dev"  = "development-eks"
    "stg"  = "staging-eks"
    "prd"  = "production-eks"
   }

  access_entry = var.cluster_mode != "management" ? {
    admin = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/argocd-access-role-${var.env}"
      policy_association = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = "cluster"
      }
    }
  } : {}
}