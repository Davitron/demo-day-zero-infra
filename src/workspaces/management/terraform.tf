terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.57"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }

    doppler = {
      source  = "DopplerHQ/doppler"
      version = ">= 1.6.1"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# provider "doppler" {
#   doppler_token = var.doppler_admin_token
# }


# variable "aws_access_key_id" {}
# variable "aws_secret_access_key" {}

variable "env" {
  description = "name of the environment"
  type        = string
  default     = "management"
}


# variable "doppler_admin_token" {
#   type = string
# }



