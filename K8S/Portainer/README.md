# Portainer managed by Argo CD

This bundle runs one Portainer CE `2.39.3` replica in `portainer`, with a
10Gi ReadWriteOnce PVC and a Recreate deployment strategy. It uses the existing
MetalLB address `10.3.0.101`, exposes HTTPS on port 443, and obtains TLS for
`portainer.jacobagtyler.com` from cert-manager's `letsencrypt-prod` ClusterIssuer.
DNS must point that hostname at `10.3.0.101`.

The September 12, 2026 backup records version `2.39.3` and exactly one environment,
`K3S Homelab`, using `https://kubernetes.default.svc`. The server service account
has cluster-admin access so it can manage this local cluster directly. No agent
or Edge tunnel is needed. `agent.yaml` is retained as a legacy reference but is
excluded from Kustomize; it is not deployed by this application.

The PVC deliberately leaves storageClassName unspecified: new installations use
the cluster default, while adoption leaves an existing claim's class intact.
Check `kubectl get storageclass` before a fresh installation. If desired, set an
explicit class before creating the claim; a bound claim's class cannot be changed
in place. Argo is instructed not to prune or delete the PVC. This does not protect
against manual namespace deletion or replace a data backup.

## Existing installation: hand over ownership first

The repo also defines Portainer in `Terraform/modules/portainer`, called from
`Terraform/main.tf`. Complete this handover before pushing the Argo application
to main, because the root application will discover and automatically sync it.

1. Take a current backup. Inspect `helm get manifest portainer -n portainer` and
   `kubectl get deploy,svc,pvc -n portainer -o yaml`. Confirm the deployment
   selector, claim name (`portainer`), requested capacity, and service address
   match this bundle. Adjust the manifests if the live objects differ. Do not
   downgrade a live instance newer than `2.39.3`.
2. Retire Terraform ownership without destroying the resources: back up Terraform
   state, remove the Portainer module call from configuration, and remove its
   resources from state (or use Terraform removed blocks with destroy disabled).
   Review the resulting plan to confirm it neither recreates nor deletes them.
   Do not run Helm uninstall: that can remove resources being adopted by Argo.
   Stop Helm upgrades for this release after handover.
3. Commit and push these manifests. Argo adopts resources with matching identities
   and reuses the existing PVC. If it contains your current Portainer database,
   no backup restore is required.
4. Once direct local connectivity is verified, the old agent deployment and its
   two services can be removed if nothing else uses them. Argo will not prune
   resources it has never managed. Leave the shared server service account intact.

## Deploy a fresh instance and restore

Prerequisites: Argo CD's `infrastructure` project, MetalLB `main-pool`, cert-manager
with the issuer above, and a working default storage class. This uses the existing
namespace and IP; it is a replacement/adoption configuration, not a simultaneous
second installation. For an independent fresh deployment, the namespace/PVC and
IP must be available first.

After committing and pushing to main, the existing root app picks up
`K8S/ArgoCD/apps/apps/portainer.yaml`. Alternatively, register it explicitly:

```bash
kubectl apply -f K8S/ArgoCD/apps/apps/portainer.yaml
kubectl rollout status deployment/portainer -n portainer --timeout=300s
kubectl get certificate,pvc,svc -n portainer
```

On a new, empty data volume, open `https://portainer.jacobagtyler.com` and choose
**Restore Portainer from backup** during initial setup, before creating an admin
account. Prefer the original downloaded `.tar.gz` archive. The individual JSON
export and database are not Kubernetes manifests and should not be put in Git.

If only the extracted directory remains, rebuild an archive locally, including
all its data (especially `portainer.key`, `portainer.pub`, `certs`, `chisel`, and
`compose`), with files at the archive root:

```bash
umask 077
COPYFILE_DISABLE=1 tar --exclude='.DS_Store' -czf /private/tmp/portainer-restore.tar.gz \
  -C /Users/jacob/Downloads/portainer-backup_2026-09-12_11-58-23 .
```

Upload that archive through the restore screen. This repackaging has not been
restore-tested; use the original archive when available. Keep the archive private
and delete the temporary copy after successful restoration. If initial setup times
out, restart the deployment and reopen the UI:

```bash
kubectl rollout restart deployment/portainer -n portainer
```

Log in with the restored credentials and confirm `K3S Homelab` is the sole
environment and is healthy. Do not add a second local environment. For a clean
installation without restoring, create the admin and select the local Kubernetes
environment once instead.

Portainer backup restores its settings, users, credentials, and stack metadata;
it does not restore workloads or their persistent data. Argo controls the
Portainer Kubernetes resources; Portainer's internal settings remain in its PVC.
Avoid editing Argo-owned workloads through Portainer because self-heal reverts
those changes. TLS files are mounted from the cert-manager Secret; restart the
Portainer deployment after certificate renewal if it continues serving the old
certificate.

References: [Portainer backup and restore](https://docs.portainer.io/admin/settings/general)
and [backup scope](https://docs.portainer.io/faqs/getting-started/what-does-portainers-backup-include).

## Local validation

```bash
kubectl kustomize K8S/Portainer
kubectl kustomize K8S/ArgoCD/apps
```

These render manifests only; successful scheduling, TLS issuance and backup
restoration require validation on the target cluster.

## Service adoption and duplicate HTTPS ports

The legacy Helm Service exposes `https` on 9443 and `edge` on 8000. This bundle
exposes `https` on 443. Apply merges Service ports by port number, which can keep
the old 9443 entry and reject the new entry with a duplicate `https` name.
The Service has `argocd.argoproj.io/sync-options: Replace=true` so Argo replaces
the specification instead of merging the port list. This overrides server-side
apply for this Service only; no `Force=true` delete/recreate is configured.
Clients using the old 9443 or 8000 ports must switch to HTTPS on 443.
See [Argo sync options](https://argo-cd.readthedocs.io/en/release-3.3/user-guide/sync-options/).
