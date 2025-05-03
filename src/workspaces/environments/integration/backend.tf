terraform {
  backend "remote" {
    organization = "DevilOps"
    workspaces {
      name = "integration"
    }
  }
}