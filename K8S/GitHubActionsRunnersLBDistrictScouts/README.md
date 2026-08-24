# LBDistrictScouts GitHub Actions runners

This runner scale set is registered at the `LBDistrictScouts` organization
level. Repositories allowed by the organization's GitHub Actions runner-group
policy can target it with:

```yaml
jobs:
  build:
    runs-on: lbdistrictscouts-runners
    steps:
      - uses: actions/checkout@v4
```

## Authentication

Create an item named `GitHub Actions Runner Controller - LBDistrictScouts` in
the 1Password `Infrastructure` vault. Add a concealed field with the exact name
`github_token` containing a fine-grained personal access token with:

- Resource owner: `LBDistrictScouts`
- Organization permission `Self-hosted runners`: read and write
- Repository access covering `DistrictBadges` and any other repositories that
  should use the scale set

The token may require approval from an organization owner. The 1Password
operator creates `github-actions-runner-auth` in the
`arc-runners-lbdistrictscouts` namespace.

After Argo CD has synchronized the application, configure the organization's
runner-group repository policy if it should be restricted to selected
repositories.
