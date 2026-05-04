#!/usr/bin/env bash
set -euo pipefail

echo "=== APIService availability ==="
kubectl get apiservice | grep miloapis

echo "=== Pod health ==="
kubectl wait --for=condition=Ready pods --all -n incidents-system --timeout=60s
kubectl wait --for=condition=Ready pods --all -n support-system --timeout=60s

echo "=== Seeded data ==="
INCIDENTS=$(kubectl get incidents.incidents.operations.miloapis.com -A --no-headers 2>/dev/null | wc -l | tr -d ' ')
[ "$INCIDENTS" -ge 3 ] || { echo "Expected >=3 incidents, got $INCIDENTS"; exit 1; }

TICKETS=$(kubectl get supporttickets.support.miloapis.com -A --no-headers 2>/dev/null | wc -l | tr -d ' ')
[ "$TICKETS" -ge 3 ] || { echo "Expected >=3 support tickets, got $TICKETS"; exit 1; }

echo "=== All kubectl checks passed ==="
