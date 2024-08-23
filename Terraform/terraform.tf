terraform { 
  cloud { 
    
    organization = "JacobAGTyler" 

    workspaces { 
      name = "homelab-prod" 
    } 
  } 
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}