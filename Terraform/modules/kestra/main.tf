# resource "kubernetes_certificate_signing_request_v1" "tls_certificate" {
#   metadata {
#     name      = "kestra-com-tls"
#   }

#   auto_approve = true

#   spec {
#     secretName = "kestra-ui-tls"  # The name of the generated TLS secret
#     issuerRef = {
#       name = "letsencrypt-prod"
#       kind = "ClusterIssuer"
#     }
#     emailSan = "jacob@jacobagtyler.com"
#     commonName = "kestra.jacobagtyler.com"
#     dnsNames   = ["kestra.jacobagtyler.com"]
#   }
# }
