#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."

cat > "$ROOT/submodules/staff-portal/.env" <<'EOF'
NODE_ENV=production
APP_URL=https://staff.localhost:30443
API_URL=https://milo-apiserver.milo-system.svc.cluster.local:6443
AUTH_OIDC_ISSUER=https://cloud.localhost:30443/oidc/v1
AUTH_OIDC_CLIENT_ID=staff-portal
AUTH_OIDC_CLIENT_SECRET=demo-secret
SESSION_SECRET=demo-session-secret-milo-demo-32ch
CLOUD_PORTAL_URL=https://cloud.localhost:30443
OTEL_ENABLED=false
NODE_TLS_REJECT_UNAUTHORIZED=0
EOF

cat > "$ROOT/submodules/cloud-portal/.env" <<'EOF'
NODE_ENV=production
APP_URL=https://cloud.localhost:30443
API_URL=https://milo-apiserver.milo-system.svc.cluster.local:6443
GRAPHQL_URL=http://localhost:8080/graphql
AUTH_OIDC_ISSUER=https://cloud.localhost:30443/oidc/v1
AUTH_OIDC_CLIENT_ID=cloud-portal
AUTH_OIDC_CLIENT_SECRET=demo-secret
SESSION_SECRET=demo-session-secret-milo-demo-32ch
PROMETHEUS_URL=http://localhost:9090
CLOUDVALID_API_URL=http://localhost:8081
CLOUDVALID_API_KEY=demo-key
CLOUDVALID_TEMPLATE_ID=demo-template
HELPSCOUT_BEACON_ID=demo-beacon
HELPSCOUT_SECRET_KEY=demo-helpscout-key
OTEL_ENABLED=false
NODE_TLS_REJECT_UNAUTHORIZED=0
EOF

echo "Portal .env files written"
