#!/usr/bin/env bash
set -euo pipefail
echo "Seeding incidents..."

# Seed IncidentSeverity objects first (cluster-scoped)
kubectl apply -f - <<'EOF'
apiVersion: incidents.operations.miloapis.com/v1alpha1
kind: IncidentSeverity
metadata:
  name: critical
spec:
  displayName: "SEV1 - Critical"
  description: "Complete outage or critical data loss affecting all users"
  color: "#FF0000"
  order: 1
---
apiVersion: incidents.operations.miloapis.com/v1alpha1
kind: IncidentSeverity
metadata:
  name: warning
spec:
  displayName: "SEV2 - Warning"
  description: "Partial outage or degraded performance affecting some users"
  color: "#FFA500"
  order: 2
---
apiVersion: incidents.operations.miloapis.com/v1alpha1
kind: IncidentSeverity
metadata:
  name: low
spec:
  displayName: "SEV3 - Low"
  description: "Minor issue with minimal user impact"
  color: "#FFFF00"
  order: 3
EOF

# Seed Incident objects (cluster-scoped)
kubectl apply -f - <<'EOF'
apiVersion: incidents.operations.miloapis.com/v1alpha1
kind: Incident
metadata:
  name: db-latency-spike
spec:
  title: "Database latency spike"
  severityRef: critical
  summary: "Primary database experiencing >2s query latency, impacting all write operations."
---
apiVersion: incidents.operations.miloapis.com/v1alpha1
kind: Incident
metadata:
  name: cdn-degraded
spec:
  title: "CDN degraded performance"
  severityRef: warning
  summary: "CDN edge nodes in us-east-1 returning elevated error rates (~5%)."
---
apiVersion: incidents.operations.miloapis.com/v1alpha1
kind: Incident
metadata:
  name: login-timeout
spec:
  title: "Login service timeout (resolved)"
  severityRef: low
  summary: "Login service experienced transient timeouts for approximately 10 minutes. Issue self-resolved."
EOF

echo "Incidents seeded"
