# Portainer manifests

Apply with:

```bash
kubectl apply -k K8S/Portainer
```

This manifest set targets the intended Portainer setup:

- Portainer on MetalLB IP `10.3.0.101`
- Portainer HTTPS exposed on port `443`
- Portainer TLS from cert-manager secret `portainer-tls`
- Portainer agent on MetalLB IP `10.3.0.213`
- Portainer agent image `portainer/agent:2.27.0`

Notes:

- Portainer still listens on container port `9443`; the `Service` maps external `443` to internal `9443`.
- The `edge` port remains on `8000`.
- These resources overlap with the current Helm-managed Portainer install. If Helm is still managing the release, a future Helm upgrade may overwrite parts of these manifests.
