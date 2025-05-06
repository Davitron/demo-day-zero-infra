locals {
  registered_environments = {
    "mgnt" = "management-eks"
    "dev"  = "development-eks"
    "stg"  = "staging-eks"
    "prd"  = "production-eks"
   }

  access_entry = var.cluster_mode != "management" ? {
    admin = {
      principal_arn = module.argocd_access_iam[0].iam_role_arn
      policy_association = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = "cluster"
      }
    }
  } : {}
}