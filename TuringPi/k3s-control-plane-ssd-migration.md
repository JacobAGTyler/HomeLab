# K3s control-plane SSD migration plan

This runbook moves the k3s `data-dir` for one control-plane node at a time onto
an attached SSD.

Use it for:

- `node1`
- `node2`
- later, if desired, `node5`

Do not run this against multiple control-plane nodes at once.

## Target design

- `node1`: control-plane + etcd on SSD-backed k3s `data-dir`
- `node2`: control-plane + etcd on SSD-backed k3s `data-dir`
- `node5`: future control-plane + etcd on separate hardware
- `node3`: worker with fast local DB storage
- `node4`: worker with second fast local DB storage

## Playbooks

- [k3s-control-plane-ssd-migration.yml](/Users/jacob/Development/Homelab/TuringPi/k3s-control-plane-ssd-migration.yml)
- [k3s-control-plane-ssd-rollback.yml](/Users/jacob/Development/Homelab/TuringPi/k3s-control-plane-ssd-rollback.yml)

## What the migration playbook does

1. Takes an etcd snapshot
2. Verifies the target disk looks blank before touching it
3. Partitions and formats the SSD
4. Mounts the SSD at `/mnt/k3s-data`
5. Stops `k3s`
6. Copies `/var/lib/rancher/k3s` to `/mnt/k3s-data/k3s`
7. Adds a k3s config drop-in pointing `data-dir` at the SSD
8. Restarts `k3s`
9. Waits for local API readiness and Ready node state

## Recommended rollout order

1. Migrate `node2`
2. Confirm the cluster is healthy
3. Migrate `node1`
4. Add new nodes later and revisit the final control-plane layout

## Assumptions

- New SSD appears as `/dev/nvme0n1`
- k3s data should live at `/mnt/k3s-data/k3s`
- Existing k3s data remains on `/var/lib/rancher/k3s`
- The migration is performed with `--limit` so only one node is touched
- The target disk is blank before the playbook runs

Adjust variables in the playbook if a node uses a different device name.

## Variables you can override per run

- `k3s_ssd_disk`
- `k3s_ssd_partition`
- `k3s_ssd_label`
- `k3s_ssd_mount_path`
- `k3s_data_dir`

Example:

```bash
ansible-playbook -i TuringPi/host-inventory.yml TuringPi/k3s-control-plane-ssd-migration.yml \
  --limit node2 \
  --extra-vars "k3s_ssd_disk=/dev/nvme1n1 k3s_ssd_partition=/dev/nvme1n1p1"
```

## Example commands

Dry-run the plan shape:

```bash
ansible-playbook -i TuringPi/host-inventory.yml TuringPi/k3s-control-plane-ssd-migration.yml --limit node2 --check
```

Run the migration on `node2`:

```bash
ansible-playbook -i TuringPi/host-inventory.yml TuringPi/k3s-control-plane-ssd-migration.yml --limit node2
```

Verify after migration:

```bash
ssh ubuntu@10.3.0.12
mount | grep /mnt/k3s-data
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl get --raw=/readyz
```

If you need to roll back:

```bash
ansible-playbook -i TuringPi/host-inventory.yml TuringPi/k3s-control-plane-ssd-rollback.yml --limit node2
```

## Manual verification checklist

- The SSD is mounted at `/mnt/k3s-data`
- `/etc/rancher/k3s/config.yaml.d/data-dir-config.yaml` exists
- `sudo systemctl status k3s` is healthy
- `sudo k3s kubectl get --raw=/readyz` returns `ok`
- The node is `Ready`
- The other control-plane nodes remain `Ready`

## Safety notes

- Keep the original `/var/lib/rancher/k3s` data until you are satisfied the
  node is stable after migration.
- Do not run this playbook against more than one control-plane node at the same
  time.
- The playbook will refuse to touch a disk that already looks partitioned or
  has a filesystem signature.
- If you later migrate to a 5-node cluster, prefer keeping only 3 etcd members.
