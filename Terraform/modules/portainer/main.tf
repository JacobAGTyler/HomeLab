resource "kubernetes_namespace" "portainer_namespace" {
  metadata {
    name = "portainer"
  }
}

resource "helm_release" "portainer" {
  name       = "portainer"
  repository = "https://portainer.github.io/k8s/"
  chart      = "portainer"
  namespace  = kubernetes_namespace.portainer_namespace.metadata[0].name
  timeout    = var.helm_timeout_seconds

  create_namespace = false

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "tls.existingSecret"
    value = "portainer-tls"
  }

  set {
    name  = "service.httpsPort"
    value = "443"
  }

  set {
    name  = "service.annotations.metallb\\.io/ip-allocated-from-pool"
    value = var.service_ip_pool
  }

  set {
    name  = "service.annotations.metallb\\.universe\\.tf/loadBalancerIPs"
    value = var.load_balancer_ip
  }

  set {
    name  = "image.tag"
    value = var.portainer_image_tag
  }

  depends_on = [kubernetes_namespace.portainer_namespace]
}

resource "kubernetes_manifest" "portainer_agent_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = merge(
      {
        name      = "portainer-agent"
        namespace = kubernetes_namespace.portainer_namespace.metadata[0].name
      },
      length(var.agent_service_annotations) > 0 ? { annotations = var.agent_service_annotations } : {}
    )
    spec = {
      type = var.agent_service_type
      selector = {
        app = "portainer-agent"
      }
      ports = [
        {
          name       = "http"
          port       = 9001
          targetPort = 9001
          protocol   = "TCP"
        }
      ]
    }
  }

  field_manager {
    name            = "terraform-portainer-agent-service"
    force_conflicts = true
  }

  depends_on = [kubernetes_namespace.portainer_namespace]
}

resource "kubernetes_manifest" "portainer_agent_headless_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "portainer-agent-headless"
      namespace = kubernetes_namespace.portainer_namespace.metadata[0].name
    }
    spec = {
      clusterIP = "None"
      selector = {
        app = "portainer-agent"
      }
    }
  }

  field_manager {
    name            = "terraform-portainer-agent-headless"
    force_conflicts = true
  }

  depends_on = [kubernetes_namespace.portainer_namespace]
}

resource "kubernetes_manifest" "portainer_agent_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "portainer-agent"
      namespace = kubernetes_namespace.portainer_namespace.metadata[0].name
    }
    spec = {
      replicas = var.agent_replicas
      selector = {
        matchLabels = {
          app = "portainer-agent"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "portainer-agent"
          }
        }
        spec = {
          serviceAccountName = "portainer-sa-clusteradmin"
          containers = [
            {
              name            = "portainer-agent"
              image           = "${var.agent_image_repository}:${var.agent_image_tag}"
              imagePullPolicy = "Always"
              ports = [
                {
                  containerPort = 9001
                  protocol      = "TCP"
                }
              ]
              env = [
                {
                  name  = "LOG_LEVEL"
                  value = var.agent_log_level
                },
                {
                  name  = "AGENT_CLUSTER_ADDR"
                  value = "portainer-agent-headless"
                },
                {
                  name = "KUBERNETES_POD_IP"
                  valueFrom = {
                    fieldRef = {
                      fieldPath = "status.podIP"
                    }
                  }
                }
              ]
            }
          ]
        }
      }
    }
  }

  field_manager {
    name            = "terraform-portainer-agent-deployment"
    force_conflicts = true
  }

  depends_on = [
    helm_release.portainer,
    kubernetes_manifest.portainer_agent_headless_service
  ]
}

resource "kubernetes_manifest" "portainer_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "portainer-tls"
      namespace = kubernetes_namespace.portainer_namespace.metadata[0].name
    }
    spec = {
      secretName = "portainer-tls"
      issuerRef = {
        name = var.cluster_issuer_name
        kind = "ClusterIssuer"
      }
      commonName = "portainer.jacobagtyler.com"
      dnsNames   = ["portainer.jacobagtyler.com"]
    }
  }

  depends_on = [kubernetes_namespace.portainer_namespace]
}
