# Argo CD bootstrap

This directory bootstraps Argo CD into the cluster and then hands cluster
configuration over to Argo CD using an app-of-apps pattern.

Pinned version:

- Argo CD `v3.3.0`

Layout:

- [install/kustomization.yaml](/Users/jacob/Development/Homelab/K8S/ArgoCD/install/kustomization.yaml): installs Argo CD from the official pinned manifest
- [install/namespace.yaml](/Users/jacob/Development/Homelab/K8S/ArgoCD/install/namespace.yaml): creates the `argocd` namespace
- [install/argocd-server-service-patch.yaml](/Users/jacob/Development/Homelab/K8S/ArgoCD/install/argocd-server-service-patch.yaml): exposes the UI/API through MetalLB on `10.3.0.105`
- [install/argocd-server-certificate.yaml](/Users/jacob/Development/Homelab/K8S/ArgoCD/install/argocd-server-certificate.yaml): requests a cert-manager certificate for `argo.jacobagtyler.com`
- [install/argocd-cm-url-patch.yaml](/Users/jacob/Development/Homelab/K8S/ArgoCD/install/argocd-cm-url-patch.yaml): sets Argo CD's external URL to `https://argo.jacobagtyler.com`
- [bootstrap/root-application.yaml](/Users/jacob/Development/Homelab/K8S/ArgoCD/bootstrap/root-application.yaml): root app pointing back at this repo
- [apps/kustomization.yaml](/Users/jacob/Development/Homelab/K8S/ArgoCD/apps/kustomization.yaml): child applications managed by the root app

Bootstrap sequence:

```bash
kubectl apply --server-side --force-conflicts -k K8S/ArgoCD/install
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
kubectl apply -f K8S/ArgoCD/bootstrap/root-application.yaml
```

If you previously applied the install before the namespace transformer was added,
some namespaced Argo CD resources may have landed in `default`. Clean those up
before reinstalling:

```bash
kubectl delete deployment,statefulset,service,serviceaccount,role,rolebinding,configmap,secret,networkpolicy -n default \
  argocd-application-controller \
  argocd-applicationset-controller \
  argocd-dex-server \
  argocd-notifications-controller \
  argocd-redis \
  argocd-repo-server \
  argocd-server \
  argocd-cm \
  argocd-cmd-params-cm \
  argocd-gpg-keys-cm \
  argocd-notifications-cm \
  argocd-rbac-cm \
  argocd-secret \
  argocd-ssh-known-hosts-cm \
  argocd-tls-certs-cm \
  argocd-notifications-secret \
  argocd-application-controller-network-policy \
  argocd-applicationset-controller-network-policy \
  argocd-dex-server-network-policy \
  argocd-notifications-controller-network-policy \
  argocd-redis-network-policy \
  argocd-repo-server-network-policy \
  argocd-server-network-policy

kubectl apply --server-side --force-conflicts -k K8S/ArgoCD/install
```

Initial access:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d && echo
```

Then log in at either:

- [https://argo.jacobagtyler.com](https://argo.jacobagtyler.com)
- [https://10.3.0.105](https://10.3.0.105)
- or use `kubectl port-forward svc/argocd-server -n argocd 8080:443` and browse to [https://localhost:8080](https://localhost:8080)

Notes:

- The root app currently manages the storage bundles in this repo.
- You can add more child applications under [apps/](/Users/jacob/Development/Homelab/K8S/ArgoCD/apps).
- This bootstrap exposes `argocd-server` via MetalLB on `10.3.0.105`.
- Add a UniFi DNS record for `argo.jacobagtyler.com` pointing to `10.3.0.105`.
- Argo CD uses the `argocd-server-tls` secret automatically when it exists, so no deployment restart should be required after the certificate is issued.
- If you want a different IP, update [argocd-server-service-patch.yaml](/Users/jacob/Development/Homelab/K8S/ArgoCD/install/argocd-server-service-patch.yaml) and reapply the install kustomization.
