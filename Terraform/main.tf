# module "traefik" {
#   source = "./modules/traefik"

#   providers = {
#     helm       = helm
#     kubernetes = kubernetes
#   }
# }

module "cert_manager" {
  source = "./modules/cert-manager"

  providers = {
    helm        = helm
    kubernetes  = kubernetes
    onepassword = onepassword
  }
}


# module "kestra" {
#   source = "./modules/kestra"

# }

module "homepage" {
  source = "./modules/homepage"

  providers = {
    kubernetes  = kubernetes
    local       = local
    onepassword = onepassword
  }
}

module "portainer" {
  source = "./modules/portainer"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  depends_on = [module.cert_manager]
}
