
resource "kubernetes_namespace" "traefik_namespace" {
  metadata {
    name = "traefik"
  }
}


resource "helm_release" "trafeik_ingress_controller" {
  name       = "traefik"

  repository = "https://traefik.github.io/charts"
  chart      = "traefik"

  namespace  = kubernetes_namespace.traefik_namespace.metadata[0].name

  set {
    name  = "entryPoints.web.address"
    value = ":80"
  }

  set {
    name = "entryPoints.dashboard.address"
    value = ":9000"
  }

  set {
    name  = "entryPoints.web.http.redirections.entryPoint.scheme"
    value = "https"
  }

  set {
    name  = "entryPoints.websecure.http.tls"
    value = "true"
  }

  set {
    name  = "entryPoints.websecure.address"
    value = ":443"
  }

  set {
    name = "dashboard.entryPoints"
    value = "traefik"
  }

  set {
    name  = "dashboard.enabled"
    value = "true"
  }

  set {
    name  = "dashboard.ingressRoute"
    value = "true"
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}


resource "kubernetes_ingress_v1" "traefik_dashboard_ingressroute" {
  metadata {
    name      = "traefik-dashboard"
    namespace = kubernetes_namespace.traefik_namespace.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
      "cert-manager.io/email-sans" = "jacob@jacobagtyler.com"
      "cert-manager.io/common-name" = "traefik.jacobagtyler.com"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
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
          path = "/"
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
  }

  spec {
    type = "LoadBalancer"

    selector = {
      "app.kubernetes.io/instance" = "traefik-traefik"
    }

    port {
      protocol = "TCP"
      port = 9000
      target_port = 9000
    }
  }
}
