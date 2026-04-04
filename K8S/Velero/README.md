# Velero

This directory now splits Velero into a Helm install and repo-managed local config.

It is tuned for this homelab in a few important ways:

- Uses the official Velero Helm chart directly through Argo CD.
- Uses the AWS plugin against an S3-compatible object store.
- Enables the node-agent and `kopia` uploader for filesystem backups.
- Disables CSI volume snapshots, which fits the current local-path and NFS-backed storage setup better.

## Version Pinning

- Velero chart: `11.4.0`
- Velero app: `1.17.1`
- AWS plugin: `1.13.1`

## Layout

- [install-values.yaml](/Users/jacob/Development/Homelab/K8S/Velero/install-values.yaml)
  Values for the Helm install app
- [config/kustomization.yaml](/Users/jacob/Development/Homelab/K8S/Velero/config/kustomization.yaml)
  Local Velero resources kept in Git

Create a 1Password item at:

- `vaults/Infrastructure/items/K3S Velero - S3 Credentials`

That item should expose a field named `cloud` whose value is:

```ini
[default]
aws_access_key_id=REPLACE_ME
aws_secret_access_key=REPLACE_ME
```

If your S3 endpoint uses a private CA, add the CA bundle to the backup storage location before applying. If it uses a public certificate, the current defaults are fine.

## What Gets Installed

- Helm install app:
  - Velero server deployment
  - Velero node-agent daemonset
  - Velero CRDs and RBAC
- Config app:
  - Backup storage location named `default`
  - 1Password-backed credentials item
  - Two schedules:
  - `daily-cluster` at `02:00`
  - `weekly-cluster` at `03:00` on Sundays

## Verify

```bash
kubectl get pods -n velero
kubectl get backupstoragelocation -n velero
kubectl get schedules -n velero
```

Healthy target state:

- `velero` deployment running
- `node-agent` daemonset running on your nodes
- `backupstoragelocation/default` available

## Notes

- This setup backs up Kubernetes resources plus filesystem-backed PV data through the node-agent.
- It is a good fit for your local SSD and NFS-backed PVCs.
- Restores are only as good as the object storage and credentials behind this setup, so put the Velero bucket somewhere you trust.
