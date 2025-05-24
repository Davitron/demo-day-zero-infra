# ------------------------------------------------------------------------------
# EKS Cluster Module
# ------------------------------------------------------------------------------

module "cluster" {
  source                                   = "../../../modules/eks"
  env                                      = var.env
  vpc_id                                   = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_version                          = "1.32"
  node_subnets                             = data.terraform_remote_state.vpc.outputs.private_subnets
  control_plane_subnet_ids                 = data.terraform_remote_state.vpc.outputs.intra_subnets
  enable_cluster_creator_admin_permissions = true
  enable_v1_permissions                    = true
  access_entry                             = local.access_entry

  aws_account_id                = data.aws_caller_identity.current.account_id
  karpenter_serviceaccount_name = var.karpenter_serviceaccount_name

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

    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.43.0-eksbuild.1"
    }
  }
}

# ------------------------------------------------------------------------------
# ArgoCD IAM Roles and Policies
# ------------------------------------------------------------------------------

resource "aws_iam_policy" "argocd_policy" {
  name        = "argocd-policy-${var.env}"
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
  version     = "~> 5.0"
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
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/argocd-management-role-management",
  ]

  create_instance_profile = false
  role_requires_mfa       = false
  attach_admin_policy     = false
}


# ------------------------------------------------------------------------------
# Crossplane IAM Role and Policies
# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------
# Cert-Manager IAM Role and Policies
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "cert_manager_route53" {
  statement {
    effect = "Allow"
    actions = [
      "route53:GetChange",
      "route53:ChangeResourceRecordSets",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets",
      "route53:ListHostedZones"
    ]
    resources = ["*"]
  }
}

module "certmanager" {
  # count   = var.env == "management" ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  create_role                = true
  role_name                  = "cert-manager-irsa-role-${var.env}"
  assume_role_condition_test = "StringLike"
  oidc_providers = {
    main = {
      provider_arn               = module.cluster.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:*"]
    }
  }
  attach_cert_manager_policy = true
}

# ------------------------------------------------------------------------------
# External DNS IAM Role and Policies
# ------------------------------------------------------------------------------

module "external_dns" {
  # count   = var.env == "management" ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  create_role                = true
  role_name                  = "external-dns-role-${var.env}"
  assume_role_condition_test = "StringLike"
  oidc_providers = {
    main = {
      provider_arn               = module.cluster.oidc_provider_arn
      namespace_service_accounts = ["external-dns:*"]
    }
  }

  attach_external_dns_policy = true
}


# ------------------------------------------------------------------------------
# Vault AWS Resources
# KMS Key and Alias
# IAM Policy for Vault
# IAM Role for Vault
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "vault_seal" {
  count      = var.cluster_mode == "management" ? 1 : 0
  bucket = "vault-seal-mgmt" 
  force_destroy = true
}


resource "aws_kms_key" "vault" {
  count      = var.cluster_mode == "management" ? 1 : 0
  description             = "KMS key for Vault auto-unseal"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "vault" {
  count      = var.cluster_mode == "management" ? 1 : 0
  name          = "alias/vault-auto-unseal"
  target_key_id = aws_kms_key.vault[0].key_id
}


data "aws_iam_policy_document" "vault" {
  count      = var.cluster_mode == "management" ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.vault[0].arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.vault_seal[0].arn}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.vault_seal[0].arn
    ]
  }
}

resource "aws_iam_policy" "vault" {
  count      = var.cluster_mode == "management" ? 1 : 0
  name        = "vault-policy"
  description = "Policy for vault to assume role"
  path        = "/"
  policy      = data.aws_iam_policy_document.vault[0].json
}


module "vault" {
  count   = var.env == "management" ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  create_role                = true
  role_name                  = "vault-kms-role"
  assume_role_condition_test = "StringLike"
  oidc_providers = {
    main = {
      provider_arn               = module.cluster.oidc_provider_arn
      namespace_service_accounts = ["vault:*"]
    }
  }

  role_policy_arns = {
    "main" = aws_iam_policy.vault[0].arn
  }
  
}