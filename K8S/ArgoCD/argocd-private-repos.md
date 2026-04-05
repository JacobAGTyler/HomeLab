# Argo CD private repository credentials

Use [repo-districtcoredata-secret.yaml](/Users/jacob/Development/Homelab/K8S/ArgoCD/apps/repo-districtcoredata-secret.yaml) to let Argo CD read the private DistrictCoreData repository through the 1Password operator.

Create this 1Password item:

- `vaults/Infrastructure/items/ArgoCD - DistrictCoreData Repository`

The Kubernetes Secret must end up with these keys for Argo CD:

- `url`
- `type`
- `username`
- `password`

Recommended values:

- `url`: `https://github.com/LBDistrictScouts/DistrictCoreData.git`
- `type`: `git`
- `username`: your GitHub username or a service account username
- `password`: a GitHub personal access token with read access to that repo

Notes:

- Argo CD reads repository credentials from Secrets labeled `argocd.argoproj.io/secret-type: repository`.
- The 1Password operator syncs the item fields into the Kubernetes Secret of the same name.
- This keeps the actual GitHub token out of Git while still making the repo credential declarative.
