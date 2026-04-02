#!/usr/bin/env bash
set -euo pipefail

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
  argocd-server-network-policy \
  --ignore-not-found
