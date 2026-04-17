# Homelab

This repository holds the infrastructure and platform configuration for the homelab, with a current focus on Kubernetes, storage, and cluster services.

## Repository Areas

- `K8S/` Kubernetes manifests and service-specific configuration
- `Terraform/` infrastructure-as-code and reusable Terraform modules
- `TuringPi/` Turing Pi and cluster node support files

## README Index

The following directories currently have their own documentation:

- [K8S/ArgoCD/README.md](K8S/ArgoCD/README.md)  
  Argo CD bootstrap and app-of-apps setup for the cluster.
- [K8S/Portainer/README.md](K8S/Portainer/README.md)  
  Portainer manifests, networking, TLS, and MetalLB exposure details.
- [K8S/Velero/README.md](K8S/Velero/README.md)  
  Velero backup configuration, version pinning, and backup schedule notes.
- [K8S/Storage/Local-DB-SSD/README.md](K8S/Storage/Local-DB-SSD/README.md)  
  Single-node local SSD storage for database workloads.
- [K8S/Storage/TrueNAS-NFS/README.md](K8S/Storage/TrueNAS-NFS/README.md)  
  TrueNAS-backed NFS storage classes for shared Kubernetes workloads.

## Notes

- The top-level README is intended as a quick navigation point for the repo.
- Add a local `README.md` in any new area that needs setup steps, design notes, or operational guidance, then link it here.

# Planned Projects

- ArgoCD Ingest:
    - Databacus
    - N8N
    - Portainer
- Infra:
    - RustFS
    - Prometheus + Monitoring
    - Alloy / Logging
    - Grafana
- Apps
    - Home Inventory System (Homebox)
    - Heimdall
    - Kestra
