# Homepage managed by Argo CD

Homepage now lives in this Kustomize bundle. The `homepage` Argo CD Application
belongs to `home-apps` and tracks `K8S/Homepage` on `main`.
Homepage uses a MetalLB LoadBalancer Service on ports 80 and 443, with an Nginx
sidecar terminating HTTPS and redirecting HTTP to HTTPS. MetalLB allocates an
available address from `main-pool`; no unverified static IP is reserved.
The `homepage-tls` Certificate uses the existing `letsencrypt-prod` ClusterIssuer
for `homepage.jacobagtyler.com`. Point that DNS name at the allocated Service IP.
The Homepage image remains `ghcr.io/gethomepage/homepage:latest`.

Configuration lives in `config/` and is generated into a ConfigMap. Its content
hash changes the Deployment reference so config edits trigger a rollout.
Home Assistant and UniFi widgets use Homepage runtime environment substitution;
the old Terraform code embedded literal `op://` references without resolving them.
The 1Password operator manages the `homepage-widget-credentials` Secret from
`vaults/Infrastructure/items/homepage-widget-credentials`, following the same
`OnePasswordItem` pattern as the other apps. No manual credential script is needed.

The Deployment explicitly maps these operator-generated keys:

| 1Password field | Secret key | Homepage environment variable |
| --- | --- | --- |
| Unify Credentials/User | User | HOMEPAGE_VAR_UNIFI_USERNAME |
| Unify Credentials/Password | Password | HOMEPAGE_VAR_UNIFI_PASSWORD |
| Home Assistant Credentials/Long Lived Token | Long-Lived-Token | HOMEPAGE_VAR_HASS_TOKEN |

The operator uses field labels without section names and replaces spaces with
hyphens. Keep these field labels unique across the item. Automatic restart is
enabled on the OnePasswordItem so credential updates restart Homepage.

## Deployment

The existing 1Password operator and CRD must be installed, watch the `homepage`
namespace, and have access to the Infrastructure vault. Argo creates the
OnePasswordItem; the operator then creates the Secret. The pod waits until the
Secret and its required keys are present.

Commit and push to main for the root Argo application to discover and sync
`K8S/ArgoCD/apps/apps/homepage.yaml`. With a working cluster context, verify:

```bash
kubectl -n homepage get onepassworditem homepage-widget-credentials
kubectl -n homepage get secret homepage-widget-credentials -o name
kubectl -n homepage get service homepage
kubectl -n homepage get certificate homepage-tls
kubectl -n homepage rollout status deployment/homepage
```

Open `homepage.jacobagtyler.com` and check the Home Assistant/UniFi widgets and
application discovery. MetalLB and the certificate issuer must be working; the pod waits for
the TLS Secret to be issued. Update DNS after the LoadBalancer IP is allocated. Live sync and operator reconciliation have not been verified locally.
The service-account-token Secret is retained for adoption compatibility.

## Automatic discovery

`config/kubernetes.yaml` enables in-cluster discovery. Add these annotations to
an application's Ingress manifest, then deploy it:

```yaml
metadata:
  annotations:
    gethomepage.dev/enabled: "true"
    gethomepage.dev/name: Homebox
    gethomepage.dev/group: Home
    gethomepage.dev/icon: homebox.png
```

Homepage does not expose an Ingress. Native Homepage discovery reads Ingress
resources, not LoadBalancer Services. Apps exposed only via LoadBalancer need
entries in `config/services.yaml` (or a separate discovery integration).
No other application's manifests are changed here.

If Argo previously managed the Homepage Ingress, pruning removes it during sync.
An old Ingress created outside Argo may require manual removal after verifying
LoadBalancer access. When the TLS Secret renews, restart the Homepage deployment
to make Nginx load the new certificate; no certificate reload controller is
configured in this bundle.

## Validation

```bash
kubectl kustomize K8S/Homepage
kubectl kustomize K8S/ArgoCD/apps
```

References: [Homepage Kubernetes setup](https://gethomepage.dev/installation/k8s/),
[runtime secrets](https://gethomepage.dev/installation/docker/#using-environment-secrets),
[1Password operator](https://developer.1password.com/docs/k8s/operator/).
