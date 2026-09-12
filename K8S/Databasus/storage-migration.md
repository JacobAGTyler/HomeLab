# Databasus SSD NFS migration

Migrated on 2026-09-12 using chart 3.21.0. The workload was stopped before
copying its data, and SHA-256 checksums matched for all 1,545 regular files.
The restarted application passed its health endpoint, including its internal
PostgreSQL check.

- Claim: `databasus/databasus-storage-databasus-0`
- Storage class: `truenas-fast-rwx`, 10 GiB, ReadWriteMany
- Active PV: `pvc-ff42fc31-5eb1-442f-b831-a742730c521d`
- Active export directory: `bee-nas.jacobagtyler.com:/mnt/SSDs/K8S/databasus/databasus-fast-migration`
- Retained original PV: `pvc-f09a6494-23b1-4f7e-9abc-0423a872ecb4` on node3
- Both data PVs have reclaim policy `Retain`.

The original PV is a pre-migration recovery copy, not a current backup. Do not
remove it until the migration has been accepted. A rollback requires stopping
the application and pausing its Argo CD reconciliation, deciding whether to
copy newer SSD data back, rebinding the claim to the retained local PV, and
recreating the StatefulSet with the original local storage settings. Simply
changing the Helm storage class cannot migrate or rebind an existing claim.

Rollback resource definitions from this session are stored locally in
`/tmp/homelab-databasus-migration`; this temporary directory is not a durable
backup. No data was copied to the local workstation.

The Helm storage settings are in `K8S/ArgoCD/apps/apps/databasus.yaml`.
Both NFS providers passed provisioning and cross-node read/write tests on
node1 and node2. Their test claims and pods were removed after verification.
