#!/usr/bin/env bash
set -euo pipefail
echo "Seeding Milo IAM users and organizations..."

MILO_TOKEN="test-admin-token"
MILO_PORT="16443"

# Re-use existing port-forward if one is already on this port, otherwise start one
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

# Seed the staff portal demo user (corresponds to demo@datum.net in Dex)
$KUBECTL_MILO apply --validate=false -f - <<'EOF'
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: demo
spec:
  email: demo@datum.net
  givenName: Demo
  familyName: User
EOF

# Seed all customer organizations from the demo Dex config
$KUBECTL_MILO apply --validate=false -f - <<'EOF'
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: acme-corp
spec:
  displayName: Acme Corp
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: brightpath
spec:
  displayName: Brightpath
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: meridian-tech
spec:
  displayName: Meridian Tech
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: cascade-analytics
spec:
  displayName: Cascade Analytics
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: vertex-systems
spec:
  displayName: Vertex Systems
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: harbor-cloud
spec:
  displayName: Harbor Cloud
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: pinnacle
spec:
  displayName: Pinnacle
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: ridgeline
spec:
  displayName: Ridgeline
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: northstar
spec:
  displayName: Northstar
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: foxhollow
spec:
  displayName: Foxhollow
  type: Standard
EOF

echo "Milo users and organizations seeded"
