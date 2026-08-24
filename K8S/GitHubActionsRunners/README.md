# GitHub Actions runners

This directory supplies authentication for an Actions Runner Controller (ARC)
runner scale set. Argo CD installs the controller into `arc-systems` and the
ephemeral runners into the separate `arc-runners` namespace.

## Before syncing

Create a 1Password item named `GitHub Actions Runner Controller` in the
`Infrastructure` vault. Add a concealed field with the exact name
`github_token`. The 1Password operator turns that item into the Kubernetes
Secret referenced by the runner scale set.

Use a fine-grained personal access token that can administer Actions runners
for `JacobAGTyler/HomeLab`. If the runner should serve an organization instead,
change `githubConfigUrl` in
`K8S/ArgoCD/apps/apps/github-actions-runners.yaml` and grant the token access to
that organization.

The scale set starts at zero runners and scales up to three. It uses Docker in
Docker, so each ephemeral runner pod is privileged. Only allow trusted
workflows to target this runner pool.

## Use from a workflow

The runner label is the Helm release name:

```yaml
jobs:
  build:
    runs-on: homelab-runners
    steps:
      - uses: actions/checkout@v4
```

Commit and push these manifests, then let the existing `homelab-root` Argo CD
application sync them. Check the result with:

```sh
kubectl -n arc-systems get pods
kubectl -n arc-runners get autoscalingrunnersets,ephemeralrunners,pods
```
