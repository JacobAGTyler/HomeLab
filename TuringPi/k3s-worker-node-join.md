# K3s worker node join plan

This playbook prepares a fresh Ubuntu node and joins it to the existing k3s cluster as a worker only.

Files:

- [k3s-worker-node-join.yml](/Users/jacob/Development/Homelab/TuringPi/k3s-worker-node-join.yml)
- [host-inventory.yml](/Users/jacob/Development/Homelab/TuringPi/host-inventory.yml)
- [ansible-requirements.yml](/Users/jacob/Development/Homelab/TuringPi/ansible-requirements.yml)

## What it does

1. Verifies the target host is allowed and the run is limited to one node.
2. Verifies `cluster_token` is defined.
3. Sets the hostname to match inventory and reboots if needed.
4. Installs baseline packages including `nfs-common`.
5. Verifies the SSD is visible and blank.
6. Partitions, formats, and mounts the SSD at `/mnt/k3s-data`.
7. Writes k3s worker config with SSD-backed `data-dir`.
8. Installs `k3s-agent`.
9. Verifies the worker becomes `Ready` from the control-plane view.

## Current intended target

- `node4`

## Before running

1. Confirm SSH works to `node4`.
2. Confirm the SSD device path is correct in [host-inventory.yml](/Users/jacob/Development/Homelab/TuringPi/host-inventory.yml).
3. Make sure `cluster_token` is available to Ansible.
4. Install the required collections if you have not already:

```bash
mkdir -p /tmp/ansible-tmp /tmp/ansible-cp
ANSIBLE_LOCAL_TEMP=/tmp/ansible-tmp ANSIBLE_SSH_CONTROL_PATH_DIR=/tmp/ansible-cp \
ansible-galaxy collection install -r TuringPi/ansible-requirements.yml
```

## Run

```bash
ansible-playbook -i TuringPi/host-inventory.yml TuringPi/k3s-worker-node-join.yml --limit node4
```

## Notes

- This joins the node as a worker only, not a control-plane server.
- It uses the SSD for the k3s data directory from the start.
- It assumes the cluster endpoint remains `https://10.3.0.11:6443`.
- If you later move to a VIP or DNS endpoint, update `k3s_cluster_server`.
- The playbook is intended to be resumable. If a previous run already created the SSD partition, filesystem, mount, or `k3s-agent` service file, a rerun should skip those parts and continue from the remaining steps.
- It will still stop if the disk layout looks inconsistent with the expected single-partition worker setup.
