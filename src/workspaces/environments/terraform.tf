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

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.0"
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
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "karpenter_serviceaccount_name" {
  
  description = "Name of the Karpenter service account"
  type        = string
}


# variable "doppler_admin_token" {
#   type = string
# }



