variable "env" {
  description = "VPC name"
  type        = string
}
variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}