terraform {
  required_version = ">= 1.7.0"
  cloud {

    organization = "JacobAGTyler"

    workspaces {
      name = "homelab-prod"
    }
  }

  required_providers {

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }

    onepassword = {
      source  = "1password/onepassword"
      version = ">= 1.0.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "homelab-k3s"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "homelab-k3s"
}


provider "onepassword" {
  account = "FGKXTWJXJFFNHFEW76RBZARQUA"

}