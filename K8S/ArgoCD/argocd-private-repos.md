# Argo CD private repository credentials

Use [repo-creds-lbdistrictscouts.yaml](/Users/jacob/Development/Homelab/K8S/ArgoCD/apps/secrets/repo-creds-lbdistrictscouts.yaml) to let Argo CD read private repositories under the `LBDistrictScouts` GitHub org through the 1Password operator.

Create this 1Password item:

- `vaults/Infrastructure/items/ArgoCD - LBD Repo Creds`

The Kubernetes Secret must end up with these keys for Argo CD:

- `url`
- `type`
- `username`
- `password`

Recommended values:

- `url`: `https://github.com/LBDistrictScouts`
- `type`: `git`
- `username`: your GitHub username or a service account username
- `password`: a GitHub personal access token with read access to the needed private repos

This org-level credential should cover:

- `https://github.com/LBDistrictScouts/DistrictCoreData.git`
- `https://github.com/LBDistrictScouts/DistrictBadges.git`
- `https://github.com/LBDistrictScouts/EventBookingBackend.git`

Notes:

- Argo CD reads shared repository credentials from Secrets labeled `argocd.argoproj.io/secret-type: repo-creds`.
- The `url` value acts as a prefix match, so using the org URL lets one credential cover multiple repos under that path.
- The 1Password operator syncs the item fields into the Kubernetes Secret of the same name.
- This keeps the actual GitHub token out of Git while still making the repo credential declarative.
