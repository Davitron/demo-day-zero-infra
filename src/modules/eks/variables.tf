variable "env" {
  description = "cluster environrment. Also serves as name of cluster"
}
variable "vpc_id" {
  description = "the vpc where the cluster is created"
}

variable "node_subnets" {
  description = "the vpc subnet where the cluster is created"
}
variable "control_plane_subnet_ids" {
  description = "VPC subnet to deploy kbs control plane to"
}
variable "master_users" {
  description = "IAM user names who can access and manage to the cluster"
  default     = []
}

variable "master_roles" {
  description = "IAM roles that can access and manage to the cluster"
  default     = []
}
variable "aws_account_id" {
  description = "AWS account ID to deploy your eks cluster"
  type        = string
}
variable "cluster_version" {
  description = "Kubernetes version to use"
  type        = string
}

variable "allowed_cidrs" {
  description = "CIDR blocks to allow access to the cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}



variable "karpenter_version" {
  description = "Karpenter version"
  type        = string
}

variable "enable_v1_permissions" {
  description = "Enable v1 permissions"
  type        = string
  default = "false"
}

variable "karpenter_serviceaccount_name" {
  description = "Name for karpenter service account"
  type        = string
  default     = "karpenter"
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Enable cluster creator admin permissions"
  type        = bool
  default     = true
}

variable "cluster_addons" {
  description = "Addons to install on the cluster"
  type = map(object({
    resolve_conflicts = string
    addon_version     = string
  }))
}

variable "create_aws_auth_configmap" {
  description = "Create aws-auth configmap"
  type        = bool
  default     = false

}

variable "manage_aws_auth_configmap" {
  description = "Manage aws-auth configmap"
  type        = bool
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

variable "instance_type" {
  description = "Instance type for the managed node group"
  type        = string
  default     = "m5.large"
}

variable "cluster_mode" {
  description = "Mode of the cluster either a management cluster or a workload cluster"
  type        = string
  validation {
    condition     = contains(["management", "workload"], var.cluster_mode)
    error_message = "cluster_mode must be either 'management' or 'workload'."
  }
  default = "management"
}