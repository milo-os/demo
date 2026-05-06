#!/usr/bin/env bash
set -euo pipefail

echo "Configuring Milo OIDC authentication for Dex..."

# Get kind node IP for hostAliases (so Milo can reach cloud.localhost:30443 internally)
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "Kind node IP: ${NODE_IP}"

# Get CA cert from envoy gateway (used to validate cloud.localhost TLS)
CA_CERT=$(kubectl get secret -n envoy-gateway-system default-tls-secret \
  -o jsonpath='{.data.ca\.crt}' | base64 -d)

# Build the auth-config.yaml content with the CA cert embedded
AUTH_CONFIG=$(python3 - <<PYEOF
import sys, textwrap

ca_cert = """${CA_CERT}"""
indented_ca = textwrap.indent(ca_cert.strip(), "                ")

config = f"""apiVersion: apiserver.config.k8s.io/v1beta1
kind: AuthenticationConfiguration
jwt:
  - issuer:
      url: https://cloud.localhost:30443/oidc/v1
      audiences:
        - cloud-portal
        - staff-portal
      audienceMatchPolicy: MatchAny
      certificateAuthority: |
{indented_ca}
    claimMappings:
      username:
        claim: name
        prefix: ""
    userValidationRules:
      - expression: "!user.username.startsWith('system:')"
        message: "username may not start with 'system:'"
"""
print(config)
PYEOF
)

# Create the OIDC auth ConfigMap
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: milo-oidc-auth-config
  namespace: milo-system
data:
  auth-config.yaml: |
$(echo "$AUTH_CONFIG" | sed 's/^/    /')
EOF

echo "ConfigMap milo-oidc-auth-config created"

# Patch Milo deployment: add env, volume, and volumeMount for the auth config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl patch deployment milo-apiserver -n milo-system --type=strategic \
  -p "$(cat "${SCRIPT_DIR}/../config/demo/milo-oidc/deployment-patch.yaml")"

# Add hostAliases so Milo can resolve cloud.localhost to the kind node
kubectl patch deployment milo-apiserver -n milo-system --type=json -p="[{
  \"op\": \"add\",
  \"path\": \"/spec/template/spec/hostAliases\",
  \"value\": [{\"ip\": \"${NODE_IP}\", \"hostnames\": [\"cloud.localhost\", \"staff.localhost\"]}]
}]"

echo "Waiting for Milo apiserver rollout..."
kubectl rollout status deployment/milo-apiserver -n milo-system --timeout=120s

echo "Milo OIDC authentication configured"
