# Local SSD storage for databases

This bundle creates a dedicated local-path provisioner for database-style
workloads that should live on the directly attached 1TB SSD in a single k3s
node.

It is intended for:

- Postgres
- MariaDB
- Redis
- other latency-sensitive `ReadWriteOnce` stateful workloads

It is not intended for:

- multi-node shared storage
- generic app data that should survive loss of a single node without restore

Files:

- [namespace.yaml](/Users/jacob/Development/Homelab/K8S/Storage/Local-DB-SSD/namespace.yaml)
- [provisioner.yaml](/Users/jacob/Development/Homelab/K8S/Storage/Local-DB-SSD/provisioner.yaml)
- [storageclass.yaml](/Users/jacob/Development/Homelab/K8S/Storage/Local-DB-SSD/storageclass.yaml)
- [example-pvc.yaml](/Users/jacob/Development/Homelab/K8S/Storage/Local-DB-SSD/example-pvc.yaml)
- [example-statefulset.yaml](/Users/jacob/Development/Homelab/K8S/Storage/Local-DB-SSD/example-statefulset.yaml)

I checked the cluster nodes and found:

- `node3` has the extra `nvme0n1` 931.5G SSD
- the drive is currently unformatted and not mounted

Before applying:

1. Format and mount the SSD on `node3` at `/mnt/db-ssd`.
2. Label the node:

```bash
kubectl label node node3 storage.homelab/db-ssd=true
```

Apply with:

```bash
kubectl apply -k K8S/Storage/Local-DB-SSD
```

Use with:

- storage class `local-db-ssd-rwo`
- node affinity targeting `storage.homelab/db-ssd=true`

Recommended placement:

- primary databases: `local-db-ssd-rwo`
- Redis: `local-db-ssd-rwo`
- backups, media, uploads: `truenas-capacity-rwx`
- shared fast files: `truenas-fast-rwx`

Important:

- This storage is fast, but it is single-node storage.
- If that node fails, the PVC is not mountable elsewhere until you restore or
  recover the node.
- For anything important, pair this with database replication and backups to
  TrueNAS.

Suggested `node3` disk bootstrap:

```bash
ssh ubuntu@10.3.0.13
sudo parted -s /dev/nvme0n1 mklabel gpt
sudo parted -s /dev/nvme0n1 mkpart primary ext4 0% 100%
sudo mkfs.ext4 -L db-ssd /dev/nvme0n1p1
sudo mkdir -p /mnt/db-ssd
UUID="$(sudo blkid -s UUID -o value /dev/nvme0n1p1)"
echo "UUID=${UUID} /mnt/db-ssd ext4 defaults,noatime 0 2" | sudo tee -a /etc/fstab
sudo mount -a
sudo chown root:root /mnt/db-ssd
sudo chmod 755 /mnt/db-ssd
```
