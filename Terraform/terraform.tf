terraform { 
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
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}