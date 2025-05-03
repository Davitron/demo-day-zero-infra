terraform {
  backend "remote" {
    organization = "DevilOps"
    workspaces {
      name = "management-eks"
    }
  }
}