variable "cluster_mode" {
  description = "Mode of the cluster either a management cluster or a workload cluster"
  type        = string
  validation {
    condition     = contains(["management", "workload"], var.cluster_mode)
    error_message = "cluster_mode must be either 'management' or 'workload'."
  }
  default = "management"
}