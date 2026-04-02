data "onepassword_vault" "route53" {
  name = var.onepassword_vault_name
}

data "onepassword_item" "route53_credentials" {
  vault = data.onepassword_vault.route53.uuid
  title = var.onepassword_item_title
}

locals {
  route53_access_key_id     = coalesce(var.route53_access_key_id, data.onepassword_item.route53_credentials.username)
  route53_secret_access_key = coalesce(var.route53_secret_access_key, data.onepassword_item.route53_credentials.password)
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  timeout    = var.helm_timeout_seconds

  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_secret" "route53_credentials" {
  metadata {
    name      = "prod-route53-credentials-secret"
    namespace = "cert-manager"
  }

  data = {
    access-key-id     = local.route53_access_key_id
    secret-access-key = local.route53_secret_access_key
  }

  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "letsencrypt_route53_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = var.cluster_issuer_name
    }
    spec = {
      acme = {
        email  = var.acme_email
        server = var.acme_server
        privateKeySecretRef = {
          name = var.cluster_issuer_private_key_secret_name
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region       = var.route53_region
                hostedZoneID = var.route53_hosted_zone_id
                accessKeyIDSecretRef = {
                  name = kubernetes_secret.route53_credentials.metadata[0].name
                  key  = "access-key-id"
                }
                secretAccessKeySecretRef = {
                  name = kubernetes_secret.route53_credentials.metadata[0].name
                  key  = "secret-access-key"
                }
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [
    helm_release.cert_manager,
    kubernetes_secret.route53_credentials
  ]
}
