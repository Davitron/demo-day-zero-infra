module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.36"

  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs = var.allowed_cidrs

  vpc_id                   = var.vpc_id
  subnet_ids               = var.node_subnets
  control_plane_subnet_ids = var.control_plane_subnet_ids

  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  cluster_addons = var.cluster_addons

  node_security_group_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = null
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m5i.large"]
  }

  eks_managed_node_groups = {
    default = {
      create_security_group                 = false
      attach_cluster_primary_security_group = true
      min_size                              = 2
      max_size                              = 5
      desired_size                          = 2
    }
  }

  tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.cluster_name
  })
}


module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.31.3"

  cluster_name                    = module.eks.cluster_name
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  enable_irsa                     = true
  irsa_namespace_service_accounts = ["karpenter:${var.karpenter_serviceaccount_name}"]
  enable_v1_permissions           = var.enable_v1_permissions

  create_instance_profile = true

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  tags = merge(tomap({
    "eks_addon" = "karpenter"
    }),
    local.tags,
  )

  depends_on = [ module.eks ]
}

