# Databasus

Access the application at https://databasus.jacobagtyler.com on the existing
MetalLB address `10.3.0.102`. Port 80 redirects to HTTPS on port 443.

Argo CD combines the Databasus 3.21.0 Helm chart with this Kustomize bundle.
The chart's service is internal on port 4005; `databasus-web` provides the
external HTTP/HTTPS endpoint through two NGINX replicas. Streaming uploads,
downloads, and WebSocket upgrades are forwarded to the application.

The `databasus-tls` Certificate uses `letsencrypt-prod` and its Route53 DNS
validation. cert-manager renews the certificate automatically. NGINX checks
its mounted certificate and configuration every 30 seconds and reloads when
they change; Kubernetes Secret projection adds its own propagation delay.

The DNS A record must continue pointing to `10.3.0.102`. The older standalone
Traefik ingress is not used for this direct LoadBalancer endpoint.

See [storage-migration.md](storage-migration.md) for the retained local
recovery volume and the active SSD NFS storage details.
