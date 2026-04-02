
resource "kubernetes_namespace" "traefik_namespace" {
  metadata {
    name = "traefik"
  }
}


# resource "helm_release" "trafeik_ingress_controller" {
#   name       = "traefik"

#   repository = "https://traefik.github.io/charts"
#   chart      = "traefik"

#   namespace  = kubernetes_namespace.traefik_namespace.metadata[0].name

#   values = [
#     "${file("${path.module}/traefik-values.yaml")}"
#   ]
# }


resource "kubernetes_ingress_v1" "traefik_dashboard_ingressroute" {
  metadata {
    name      = "traefik-dashboard"
    namespace = kubernetes_namespace.traefik_namespace.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class"    = "traefik"
      "cert-manager.io/email-sans"     = "jacob@jacobagtyler.com"
      "cert-manager.io/common-name"    = "traefik.jacobagtyler.com"
      "cert-manager.io/cluster-issuer" = "letsencrypt-route53-prod"
    }
  }

  spec {
    ingress_class_name = "traefik"

    # tls {
    #   hosts = ["traefik.jacobagtyler.com"]
    #   secret_name = "traefik-tls"
    # }

    rule {
      host = "traefik.jacobagtyler.com"

      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "traefik-dashboard"
              port {
                number = 9000
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "traefik_dashboard" {
  metadata {
    name      = "traefik-dashboard"
    namespace = kubernetes_namespace.traefik_namespace.metadata[0].name

    annotations = {
      "metallb.io/ip-allocated-from-pool"   = "main-pool"
      "metallb.universe.tf/loadBalancerIPs" = "10.3.0.211"
    }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      "app.kubernetes.io/instance" = "traefik-traefik"
    }

    port {
      protocol    = "TCP"
      port        = 9000
      target_port = 9000
    }
  }
}


resource "kubernetes_secret" "traefik_route53_creds_secret" {
  metadata {
    name      = "prod-route53-credentials-secret"
    namespace = kubernetes_namespace.traefik_namespace.metadata[0].name
  }

  data = {
    access-key-id     = "op://Developer/K3S Cert Manager - AWS IAM Credentials/username"
    secret-access-key = "op://Developer/K3S Cert Manager - AWS IAM Credentials/credential"
  }

}
