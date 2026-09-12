# TrueNAS-backed Kubernetes storage

This bundle creates two independent NFS provisioners backed by two separate
TrueNAS SCALE appliances with different performance profiles.

It gives you:

- `truenas-capacity-rwx`: dynamic `ReadWriteMany` storage on the HDD-backed NAS
- `truenas-fast-rwx`: dynamic `ReadWriteMany` storage on the all-SSD NAS
- a shared `truenas-nfs-provisioner` namespace
- a simple smoke test PVC for each storage class

Apply with:

```bash
kubectl apply -k K8S/Storage/TrueNAS-NFS
```

Before you apply:

1. Confirm the HDD export in [provisioner-truenas-a.yaml](provisioner-truenas-a.yaml):
   `terra-nas.jacobagtyler.com:/mnt/HDDs/K8S`.
2. Confirm the SSD export in [provisioner-truenas-b.yaml](provisioner-truenas-b.yaml):
   `bee-nas.jacobagtyler.com:/mnt/SSDs/K8S`.
   Both Kubernetes exports allow node IPs `10.3.0.11` through `10.3.0.15` and map
   client root to root so the provisioner can create PVC directories. Update
   each export's host list when adding nodes. NFS is enabled at boot.
3. Make sure every k3s node has NFS client packages installed.
   - On Ubuntu/Debian that is usually `nfs-common`
   - You can install it across the cluster with [install-nfs-client.yml](/Users/jacob/Development/Homelab/TuringPi/install-nfs-client.yml)
4. Make sure each TrueNAS export allows mounts from your node network.

Install the node-side NFS packages if you have not already:

```bash
ansible-playbook -i TuringPi/host-inventory.yml TuringPi/install-nfs-client.yml
```

Smoke test:

```bash
kubectl apply -f K8S/Storage/TrueNAS-NFS/smoke-test.yaml
kubectl get pvc -n truenas-nfs-provisioner
kubectl exec -n truenas-nfs-provisioner deploy/storage-smoke-test -- sh -c 'ls -la /mnt/a && ls -la /mnt/b'
```

Cleanup smoke test:

```bash
kubectl delete -f K8S/Storage/TrueNAS-NFS/smoke-test.yaml
```

Notes:

- This is resilient in the sense that your cluster can use either NAS, and you
  can place workloads on one or the other.
- It is not synchronous shared-storage HA by itself. If one NAS dies, PVCs on
  that NAS are still unavailable until the workload is restored elsewhere.
- Use `truenas-capacity-rwx` for backups, media, and larger shared datasets.
- Use `truenas-fast-rwx` for latency-sensitive app data that still fits NFS.
- For databases, prefer app-level replication or an iSCSI-backed `ReadWriteOnce`
  class on the SSD NAS instead of putting primary database files on shared NFS.
