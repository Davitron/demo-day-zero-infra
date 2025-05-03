module "management-cluster" {
  source                                   = "../../../modules/eks"
  env                                      = var.env
  vpc_id                                   = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_version                          = "1.32"
  node_subnets                             = data.terraform_remote_state.vpc.outputs.private_subnets
  control_plane_subnet_ids                 = data.terraform_remote_state.vpc.outputs.intra_subnets
  enable_cluster_creator_admin_permissions = true
  enable_v1_permissions                    = true 

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
  description = "Policy for argocd"
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


module "argocd_iam" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version     = "5.34.0"
  create_role = true
  role_name   = "argocd-role"
  oidc_providers = {
    main = {
      provider_arn = module.control-cluster.oidc_provider_arn
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
  name       = "argocd-policy-attachment"
  roles      = [module.argocd_iam.iam_role_name]
  policy_arn = aws_iam_policy.argocd_policy.arn

}

module "crossplane_iam" {
  source                     = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                    = "~> 5.0"
  create_role                = true
  role_name                  = "crossplane-role-${var.env}"
  assume_role_condition_test = "StringLike"
  oidc_providers = {
    main = {
      provider_arn               = module.control-cluster.oidc_provider_arn
      namespace_service_accounts = ["crossplane:*"]
    }
  }
  role_policy_arns = {
    "admin" = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
}