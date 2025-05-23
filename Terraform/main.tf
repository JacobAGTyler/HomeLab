module "traefik" {
  source = "./modules/traefik"
  
  providers = {
    helm = helm
    kubernetes = kubernetes
  }
}


module "kestra" {
  source = "./modules/kestra"
  
}

module "homepage" {
  source = "./modules/homepage"
  
  providers = {
    kubernetes = kubernetes
    local = local
    onepassword = onepassword
  }
}