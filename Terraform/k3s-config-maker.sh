#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOTE_KUBECONFIG="/Users/jacob/Downloads/k3s-export.yaml"
LOCAL_KUBECONFIG="${HOME}/.kube/config"

if [[ ! -f "${REMOTE_KUBECONFIG}" ]]; then
  echo "Error: ${REMOTE_KUBECONFIG} not found"
  exit 1
fi

mkdir -p "${HOME}/.kube"

if [[ -f "${LOCAL_KUBECONFIG}" ]]; then
  BACKUP="${LOCAL_KUBECONFIG}.backup.$(date +%Y%m%d-%H%M%S)"
  cp "${LOCAL_KUBECONFIG}" "${BACKUP}"
  echo "Backed up existing kubeconfig to: ${BACKUP}"
else
  touch "${LOCAL_KUBECONFIG}"
fi

# Merge + flatten
KUBECONFIG="${LOCAL_KUBECONFIG}:${REMOTE_KUBECONFIG}" \
  kubectl config view --flatten > "${LOCAL_KUBECONFIG}.new"

mv "${LOCAL_KUBECONFIG}.new" "${LOCAL_KUBECONFIG}"
chmod 600 "${LOCAL_KUBECONFIG}"

echo "Available contexts:"
kubectl config get-contexts

echo
echo "Import complete from: ${REMOTE_KUBECONFIG}"
