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