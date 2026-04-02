# CertManager and MetalLB Argo CD adoption plan

This plan is for adopting the **configuration** of cert-manager and MetalLB
into Argo CD, while leaving the currently working controller installations
alone for now.

## What Argo CD should own

### cert-manager

Argo CD should own:

- [route53-credentials-onepassworditem.yaml](/Users/jacob/Development/Homelab/K8S/CertManager/route53-credentials-onepassworditem.yaml)
- [route53-issuer.yaml](/Users/jacob/Development/Homelab/K8S/CertManager/route53-issuer.yaml)

Argo CD should not yet own:

- the cert-manager controller installation
- its Deployments/Services/CRDs

### MetalLB

Argo CD should own:

- [ipaddresspool-main.yaml](/Users/jacob/Development/Homelab/K8S/metalLB/ipaddresspool-main.yaml)
- [l2advertisement-main.yaml](/Users/jacob/Development/Homelab/K8S/metalLB/l2advertisement-main.yaml)

Argo CD should not yet own:

- the MetalLB controller/speaker installation

## Why this is the safe approach

- It avoids ownership fights with already-installed controller resources.
- It lets Argo CD own the declarative configuration that changes over time.
- It minimizes disruption while your cluster API is still intermittently slow.

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
   - `cert-manager-config`
   - `metallb-config`
3. Confirm both apps show `Synced`.
4. Check for drift.
5. Only later, if you really want full takeover, retire the old install method
   first and then let Argo install the controllers.

## Warning signs to watch for

- Repeated OutOfSync loops on `letsencrypt-prod`
- `prod-route53-credentials-secret` not appearing from 1Password
- MetalLB config no longer matching the live pool/adverts
- cert-manager issuer or credential source no longer matching the live setup

## Suggested verification

```bash
kubectl get application -n argocd
kubectl get clusterissuer letsencrypt-prod -o yaml
kubectl get ipaddresspool,l2advertisement -n metallb-system
```
