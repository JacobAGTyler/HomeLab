# Portainer manifests

Apply with:

```bash
kubectl apply -k K8S/Portainer
```

This manifest set keeps Portainer on the MetalLB IP `10.3.0.101`, serves HTTPS on port `443`, and uses a cert-manager `Certificate` named `portainer-tls` issued by the `letsencrypt-prod` `ClusterIssuer`.

Notes:

- Portainer itself still listens on container port `9443`; the `Service` maps external `443` to internal `9443`.
- The `edge` port remains on `8000`.
- These resources overlap with the current Helm-managed Portainer install. If Helm is still managing the release, a future Helm upgrade may overwrite parts of these manifests.
