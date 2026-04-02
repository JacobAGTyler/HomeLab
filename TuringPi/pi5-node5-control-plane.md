# Raspberry Pi 5 node5 control-plane plan

This playbook prepares a Raspberry Pi 5 with an NVMe SSD and joins it to the
existing k3s cluster as a control-plane + etcd server.

Files:

- [pi5-node5-control-plane.yml](/Users/jacob/Development/Homelab/TuringPi/pi5-node5-control-plane.yml)
- [host-inventory.yml](/Users/jacob/Development/Homelab/TuringPi/host-inventory.yml)
- [ansible-requirements.yml](/Users/jacob/Development/Homelab/TuringPi/ansible-requirements.yml)

## Before running

1. Update `node5` in [host-inventory.yml](/Users/jacob/Development/Homelab/TuringPi/host-inventory.yml):
   - `ansible_host`
   - `ansible_password`
2. Confirm the Pi 5 boots correctly and SSH works.
3. Confirm the NVMe device path on node5.
4. Make sure `cluster_token` is available to Ansible the same way you already use it for the other k3s playbooks.

## Install required Ansible collections

Because the migration and Pi 5 playbooks use `community.general` and
`ansible.posix`, install them with:

```bash
mkdir -p /tmp/ansible-tmp /tmp/ansible-cp
ANSIBLE_LOCAL_TEMP=/tmp/ansible-tmp ANSIBLE_SSH_CONTROL_PATH_DIR=/tmp/ansible-cp \
ansible-galaxy collection install -r TuringPi/ansible-requirements.yml
```

## Run the playbook

```bash
ansible-playbook -i TuringPi/host-inventory.yml TuringPi/pi5-node5-control-plane.yml
```

## After node5 joins

1. Verify `node5` is Ready.
2. Confirm the cluster still has healthy quorum.
3. Only then start planning the removal of control-plane/etcd duties from `node3`.

## Notes

- This playbook joins `node5` as a `server`, not an agent.
- It uses SSD-backed `data-dir` from the start.
- It assumes the advertised cluster endpoint remains `https://10.3.0.11:6443`.
- If you later introduce an API VIP, update the base/control-plane config accordingly.
