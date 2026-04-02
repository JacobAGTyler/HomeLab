#!/usr/bin/env bash
set -euo pipefail

max_attempts="${TF_APPLY_MAX_ATTEMPTS:-6}"
sleep_seconds="${TF_APPLY_RETRY_SLEEP_SECONDS:-15}"

if ! [[ "$max_attempts" =~ ^[0-9]+$ ]] || [ "$max_attempts" -lt 1 ]; then
  echo "TF_APPLY_MAX_ATTEMPTS must be a positive integer" >&2
  exit 2
fi

if ! [[ "$sleep_seconds" =~ ^[0-9]+$ ]] || [ "$sleep_seconds" -lt 1 ]; then
  echo "TF_APPLY_RETRY_SLEEP_SECONDS must be a positive integer" >&2
  exit 2
fi

attempt=1
while [ "$attempt" -le "$max_attempts" ]; do
  echo "terraform apply attempt ${attempt}/${max_attempts}"
  if terraform apply -parallelism=1 -lock-timeout=5m "$@"; then
    exit 0
  fi

  if [ "$attempt" -eq "$max_attempts" ]; then
    echo "terraform apply failed after ${max_attempts} attempts" >&2
    exit 1
  fi

  echo "apply failed; retrying in ${sleep_seconds}s..."
  sleep "$sleep_seconds"
  attempt=$((attempt + 1))
done
