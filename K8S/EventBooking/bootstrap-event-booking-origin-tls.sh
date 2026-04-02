#!/usr/bin/env bash
set -euo pipefail

HOSTNAME="event-backend.jacobagtyler.com"
NAMESPACE="event-booking"
SECRET_NAME="event-booking-backend-tls"
MANIFEST="$(dirname "$0")/event-booking-origin-tls.yaml"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout "$tmpdir/tls.key" \
  -out "$tmpdir/tls.crt" \
  -days 7 \
  -subj "/CN=${HOSTNAME}" \
  -addext "subjectAltName=DNS:${HOSTNAME}" >/dev/null 2>&1

kubectl -n "${NAMESPACE}" create secret tls "${SECRET_NAME}" \
  --cert="$tmpdir/tls.crt" \
  --key="$tmpdir/tls.key" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" delete ingress event-booking-backend --ignore-not-found
kubectl -n "${NAMESPACE}" delete certificaterequest -l cert-manager.io/certificate-name="${SECRET_NAME}" --ignore-not-found
kubectl -n "${NAMESPACE}" delete order,challenge --all --ignore-not-found

kubectl apply -f "${MANIFEST}"
kubectl -n "${NAMESPACE}" rollout restart deploy/event-booking
kubectl -n "${NAMESPACE}" rollout status deploy/event-booking --timeout=180s

echo
echo "Bootstrap complete."
echo "HTTPS origin should now answer on https://${HOSTNAME} and https://10.3.0.103/"
echo "Cert-manager will replace the temporary certificate in secret ${SECRET_NAME} once DNS-01 validation succeeds."
