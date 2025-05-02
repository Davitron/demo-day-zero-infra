terraform {
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
  required_version = ">= 1.5.0"
}