resource "kubernetes_namespace" "homepage_namespace" {
  metadata {
    name = "homepage"
  }
}

locals {
    homepage_manifests = fileset("${path.module}/manifests", "*.yml")
}

data "local_file" "homepage_manifest_files" {
  for_each = local.homepage_manifests
  filename = "${path.module}/manifests/${each.value}"
}

resource "kubernetes_manifest" "homepage_manifests" {
  for_each = data.local_file.homepage_manifest_files

  manifest = yamldecode(each.value.content)
}


locals {
  credentials = {
    hass_token = "op://Developer/Homepage - Dev Dashboard/Home Assistant Credentials/Long Lived Token"
    unifi_username = "op://Developer/Homepage - Dev Dashboard/Unify Credentials/User"
    unifi_password = "op://Developer/Homepage - Dev Dashboard/Unify Credentials/Password"
  }
}

resource "kubernetes_secret" "homepage_config" {
  metadata {
    name = "homepage-config"
    namespace = kubernetes_namespace.homepage_namespace.metadata.0.name

    labels = {
      "app.kubernetes.io/name" = "homepage"
    }
  }    

  data = {
    "bookmarks.yaml" = file("${path.module}/homepage-configs/bookmarks.yaml")
    "kubernetes.yaml" = file("${path.module}/homepage-configs/kubernetes.yaml")
    "services.yaml" = templatefile("${path.module}/homepage-configs/services.yaml", local.credentials)
    "widgets.yaml" = templatefile("${path.module}/homepage-configs/widgets.yaml", local.credentials)
    "settings.yaml" = ""
    "custom.css" = ""
    "custom.js" = ""
    "docker.yaml" = ""
  }
}

resource "kubernetes_deployment_v1" "homepage_deployment" {
  metadata {
    name = "homepage"
    namespace = kubernetes_namespace.homepage_namespace.metadata.0.name

    labels = {
      "app.kubernetes.io/name" = "homepage"
    }
  }
  
  spec {
    replicas = 1
    revision_history_limit = 3
    strategy {
      type = "RollingUpdate"
    }
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "homepage"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "homepage"
        }
      }

      spec {
        service_account_name = "homepage"
        automount_service_account_token = true
        dns_policy = "ClusterFirst"
        enable_service_links = true

        container {
          name = "homepage"
          image = "ghcr.io/gethomepage/homepage:latest"
          image_pull_policy = "Always"

          resources {
            limits = {
              memory = "128Mi"
              cpu = "500m"
            }
          }

          port {
            name = "http"
            container_port = 3000
            protocol = "TCP"
          }

          volume_mount {
            mount_path = "/app/config"
            name = "homepage-config"
            sub_path = "."
          }

          volume_mount {
            mount_path = "/app/config/logs"
            name = "logs"
          }
        }

        volume {
          name = "homepage-config"
          secret {
            secret_name = kubernetes_secret.homepage_config.metadata.0.name
          }
        }

        volume {
          name = "logs"
          empty_dir {}
        }
      }
    }
  }
}

#           volumeMounts:
#             - mountPath: /app/config/custom.js
#               name: homepage-config
#               subPath: custom.js
#             - mountPath: /app/config/custom.css
#               name: homepage-config
#               subPath: custom.css
#             - mountPath: /app/config/bookmarks.yaml
#               name: homepage-config
#               subPath: bookmarks.yaml
#             - mountPath: /app/config/docker.yaml
#               name: homepage-config
#               subPath: docker.yaml
#             - mountPath: /app/config/kubernetes.yaml
#               name: homepage-config
#               subPath: kubernetes.yaml
#             - mountPath: /app/config/services.yaml
#               name: homepage-config
#               subPath: services.yaml
#             - mountPath: /app/config/settings.yaml
#               name: homepage-config
#               subPath: settings.yaml
#             - mountPath: /app/config/widgets.yaml
#               name: homepage-config
#               subPath: widgets.yaml
#             - mountPath: /app/config/logs
#               name: logs
#       volumes:
#         - name: homepage-config
#           sedret:
#             name: homepage-config
#         - name: logs
#           emptyDir: {}