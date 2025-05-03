locals {
  access_entry = var.cluster_mode != "management" ? {
    admin = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/argocd-access-role-${var.env}"
      policy_association = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = "cluster"
      }
    }
  } : {}

  environment_alias = {
    mgnt = "management"
  }
}


module "cluster" {
  source                                   = "../../../modules/eks"
  env                                      = var.env
  vpc_id                                   = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_version                          = "1.32"
  node_subnets                             = data.terraform_remote_state.vpc.outputs.private_subnets
  control_plane_subnet_ids                 = data.terraform_remote_state.vpc.outputs.intra_subnets
  enable_cluster_creator_admin_permissions = true
  enable_v1_permissions                    = true
  access_entry = local.access_entry

  aws_account_id = "${data.aws_caller_identity.current.account_id}"

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.11.4-eksbuild.2"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.32.0-eksbuild.2"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.19.2-eksbuild.5"
    }
  }
}


resource "aws_iam_policy" "argocd_policy" {
  name        = "argocd-policy"
  description = "Policy for argocd to assume role"
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sts:AssumeRole"
        ],
        Resource = "*"
      },
    ]
  })
}


module "argocd_management_iam" {
  count       = var.cluster_mode == "management" ? 1 : 0 
  source      = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                    = "~> 5.0"
  create_role = true
  role_name   = "argocd-management-role-${var.env}"
  oidc_providers = {
    main = {
      provider_arn = module.cluster.oidc_provider_arn
      namespace_service_accounts = [
        "argocd:argocd-role",
        "argocd:argocd-application-controller",
        "argocd:argocd-dex-server",
        "argocd:argocd-notifications-controller",
        "argocd:argocd-server",
        "argocd:argocd-repo-server",
        "argocd:argocd-applicationset-controller",
      ]
      role_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      ]
    }
  }
}

resource "aws_iam_policy_attachment" "argocd_policy_attachment" {
  count      = var.cluster_mode == "management" ? 1 : 0
  name       = "argocd-policy-attachment"
  roles      = [module.argocd_management_iam[0].iam_role_name]
  policy_arn = aws_iam_policy.argocd_policy.arn

}

module "argocd_access_iam" {
  count       = var.cluster_mode == "workload" ? 1 : 0
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version     = "5.34.0"
  create_role = true
  role_name   = "argocd-access-role-${var.env}"
  trusted_role_arns = [
    module.argocd_management_iam[0].iam_role_arn,
  ]

  create_instance_profile = false
  role_requires_mfa       = false
  attach_admin_policy     = false
}


module "crossplane_iam" {
  source                     = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                    = "~> 5.0"
  create_role                = true
  role_name                  = "crossplane-role-${var.env}"
  assume_role_condition_test = "StringLike"
  oidc_providers = {
    main = {
      provider_arn               = module.cluster.oidc_provider_arn
      namespace_service_accounts = ["crossplane:*"]
    }
  }
  role_policy_arns = {
    "admin" = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
}