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

# Hand Homepage resources to Argo CD without deleting the live installation.
removed {
  from = module.homepage
  lifecycle {
    destroy = false
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
