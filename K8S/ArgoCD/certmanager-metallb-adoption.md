# CertManager and MetalLB Argo CD adoption plan

This plan is for adopting the **full definition** of cert-manager and MetalLB
into Argo CD, while still sequencing the takeover safely.

## What Argo CD should own

### cert-manager

Argo CD should own:

- the cert-manager Helm install
- [route53-credentials-onepassworditem.yaml](/Users/jacob/Development/Homelab/K8S/CertManager/route53-credentials-onepassworditem.yaml)
- [route53-issuer.yaml](/Users/jacob/Development/Homelab/K8S/CertManager/route53-issuer.yaml)

with:

- `cert-manager-install` synced before `cert-manager-config`

### MetalLB

Argo CD should own:

- the MetalLB Helm install
- [ipaddresspool-main.yaml](/Users/jacob/Development/Homelab/K8S/metalLB/ipaddresspool-main.yaml)
- [l2advertisement-main.yaml](/Users/jacob/Development/Homelab/K8S/metalLB/l2advertisement-main.yaml)

with:

- `metallb-install` synced before `metallb-config`

## Why this is the safe approach

- It gives Argo CD ownership of both installs and config.
- It pins install versions to what is already running:
  - cert-manager `v1.20.0`
  - MetalLB chart `0.14.9`
- It still separates install and config so resources appear in a predictable
  order.

## Current comparison summary

- The live `ClusterIssuer letsencrypt-prod` matches the checked-in
  [route53-issuer.yaml](/Users/jacob/Development/Homelab/K8S/CertManager/route53-issuer.yaml).
- The live MetalLB pool/advertisement match the cleaned manifests in
  [K8S/metalLB](/Users/jacob/Development/Homelab/K8S/metalLB).
- The old Terraform cert-manager module uses a different secret-key shape than
  the checked-in YAML and should not be treated as the source of truth for the
  issuer moving forward.

## Recommended handoff sequence

1. Commit and push the new Argo app definitions.
2. Let Argo CD create:
   - `cert-manager-install`
   - `cert-manager-config`
   - `metallb-install`
   - `metallb-config`
3. Confirm both apps show `Synced`.
4. Check for drift or ownership fights.
5. After Argo is healthy, retire the old non-Argo install path to avoid
   long-term ownership fights.

## Warning signs to watch for

- Repeated OutOfSync loops on `letsencrypt-prod`
- `prod-route53-credentials-secret` not appearing from 1Password
- MetalLB app trying to prune resources still actively managed elsewhere
- cert-manager install app fighting Terraform/previous Helm ownership

## Suggested verification

```bash
kubectl get application -n argocd
kubectl get clusterissuer letsencrypt-prod -o yaml
kubectl get ipaddresspool,l2advertisement -n metallb-system
```
