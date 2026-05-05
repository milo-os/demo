#!/usr/bin/env bash
set -euo pipefail

MILO_TOKEN="test-admin-token"
MILO_PORT="16443"

if ! curl -sk "https://localhost:${MILO_PORT}/healthz" >/dev/null 2>&1; then
  kubectl port-forward -n milo-system svc/milo-apiserver "${MILO_PORT}:6443" &
  PF_PID=$!
  trap "kill ${PF_PID} 2>/dev/null || true" EXIT

  for i in $(seq 1 20); do
    if curl -sk "https://localhost:${MILO_PORT}/healthz" >/dev/null 2>&1; then break; fi
    sleep 1
  done
fi

KUBECTL_MILO="kubectl --server=https://localhost:${MILO_PORT} --insecure-skip-tls-verify --token=${MILO_TOKEN}"

echo "=== APIService availability ==="
$KUBECTL_MILO get apiservice | grep miloapis

echo "=== Pod health ==="
kubectl wait --for=condition=Ready pods --all -n incidents-system --timeout=60s
kubectl wait --for=condition=Ready pods --all -n support-system --timeout=60s

echo "=== Seeded data ==="
INCIDENTS=$($KUBECTL_MILO get incidents.incidents.operations.miloapis.com -A --no-headers 2>/dev/null | wc -l | tr -d ' ')
[ "$INCIDENTS" -ge 3 ] || { echo "Expected >=3 incidents, got $INCIDENTS"; exit 1; }

TICKETS=$($KUBECTL_MILO get supporttickets.support.miloapis.com -A --no-headers 2>/dev/null | wc -l | tr -d ' ')
[ "$TICKETS" -ge 3 ] || { echo "Expected >=3 support tickets, got $TICKETS"; exit 1; }

echo "=== All kubectl checks passed ==="
