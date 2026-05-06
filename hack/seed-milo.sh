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

# Seed staff portal users (correspond to datum.net users in Dex)
$KUBECTL_MILO apply --validate=false -f - <<'EOF'
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: demo
spec:
  email: demo@datum.net
  givenName: Demo
  familyName: User
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: alice
spec:
  email: alice@datum.net
  givenName: Alice
  familyName: Datum
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: bob
spec:
  email: bob@datum.net
  givenName: Bob
  familyName: Datum
EOF

# Seed cloud portal users (customer org members from Dex staticPasswords).
# usernames match the Dex 'username' field, which becomes the 'name' JWT claim
# and therefore the Milo identity used by the cloud portal.
$KUBECTL_MILO apply --validate=false -f - <<'EOF'
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: james.hartwell
spec:
  email: james.hartwell@acme-corp.example
  givenName: James
  familyName: Hartwell
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: emma.sutton
spec:
  email: emma.sutton@acme-corp.example
  givenName: Emma
  familyName: Sutton
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: oliver.crane
spec:
  email: oliver.crane@acme-corp.example
  givenName: Oliver
  familyName: Crane
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: sophia.morales
spec:
  email: sophia.morales@acme-corp.example
  givenName: Sophia
  familyName: Morales
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: william.ford
spec:
  email: william.ford@acme-corp.example
  givenName: William
  familyName: Ford
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: ava.chen
spec:
  email: ava.chen@brightpath.example
  givenName: Ava
  familyName: Chen
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: noah.patel
spec:
  email: noah.patel@brightpath.example
  givenName: Noah
  familyName: Patel
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: isabella.ross
spec:
  email: isabella.ross@brightpath.example
  givenName: Isabella
  familyName: Ross
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: liam.warner
spec:
  email: liam.warner@brightpath.example
  givenName: Liam
  familyName: Warner
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: mia.kowalski
spec:
  email: mia.kowalski@brightpath.example
  givenName: Mia
  familyName: Kowalski
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: benjamin.shaw
spec:
  email: b.shaw@meridian-tech.example
  givenName: Benjamin
  familyName: Shaw
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: charlotte.tran
spec:
  email: c.tran@meridian-tech.example
  givenName: Charlotte
  familyName: Tran
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: lucas.osei
spec:
  email: l.osei@meridian-tech.example
  givenName: Lucas
  familyName: Osei
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: amelia.byrne
spec:
  email: a.byrne@meridian-tech.example
  givenName: Amelia
  familyName: Byrne
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: mason.lin
spec:
  email: m.lin@meridian-tech.example
  givenName: Mason
  familyName: Lin
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: harper.nkosi
spec:
  email: harper@cascade-analytics.example
  givenName: Harper
  familyName: Nkosi
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: ethan.vasquez
spec:
  email: ethan@cascade-analytics.example
  givenName: Ethan
  familyName: Vasquez
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: evelyn.price
spec:
  email: evelyn@cascade-analytics.example
  givenName: Evelyn
  familyName: Price
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: henry.dougherty
spec:
  email: henry@cascade-analytics.example
  givenName: Henry
  familyName: Dougherty
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: abigail.kim
spec:
  email: abigail@cascade-analytics.example
  givenName: Abigail
  familyName: Kim
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: alexander.hunt
spec:
  email: alex.hunt@vertex-systems.example
  givenName: Alexander
  familyName: Hunt
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: emily.santos
spec:
  email: emily.santos@vertex-systems.example
  givenName: Emily
  familyName: Santos
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: michael.porter
spec:
  email: michael.porter@vertex-systems.example
  givenName: Michael
  familyName: Porter
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: elizabeth.reed
spec:
  email: e.reed@vertex-systems.example
  givenName: Elizabeth
  familyName: Reed
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: daniel.berg
spec:
  email: d.berg@vertex-systems.example
  givenName: Daniel
  familyName: Berg
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: matthew.quinn
spec:
  email: m.quinn@harbor-cloud.example
  givenName: Matthew
  familyName: Quinn
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: avery.hoffman
spec:
  email: a.hoffman@harbor-cloud.example
  givenName: Avery
  familyName: Hoffman
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: jackson.mills
spec:
  email: j.mills@harbor-cloud.example
  givenName: Jackson
  familyName: Mills
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: ella.thornton
spec:
  email: e.thornton@harbor-cloud.example
  givenName: Ella
  familyName: Thornton
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: sebastian.holt
spec:
  email: s.holt@harbor-cloud.example
  givenName: Sebastian
  familyName: Holt
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: scarlett.novak
spec:
  email: s.novak@pinnacle.io.example
  givenName: Scarlett
  familyName: Novak
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: aiden.walsh
spec:
  email: a.walsh@pinnacle.io.example
  givenName: Aiden
  familyName: Walsh
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: victoria.lane
spec:
  email: v.lane@pinnacle.io.example
  givenName: Victoria
  familyName: Lane
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: jack.obrien
spec:
  email: jack.obrien@pinnacle.io.example
  givenName: Jack
  familyName: Obrien
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: madison.frost
spec:
  email: m.frost@pinnacle.io.example
  givenName: Madison
  familyName: Frost
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: owen.callahan
spec:
  email: o.callahan@ridgeline.example
  givenName: Owen
  familyName: Callahan
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: luna.espinoza
spec:
  email: l.espinoza@ridgeline.example
  givenName: Luna
  familyName: Espinoza
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: samuel.west
spec:
  email: s.west@ridgeline.example
  givenName: Samuel
  familyName: West
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: grace.mackenzie
spec:
  email: g.mackenzie@ridgeline.example
  givenName: Grace
  familyName: Mackenzie
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: david.yuen
spec:
  email: d.yuen@ridgeline.example
  givenName: David
  familyName: Yuen
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: chloe.ingram
spec:
  email: c.ingram@northstar.example
  givenName: Chloe
  familyName: Ingram
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: joseph.brennan
spec:
  email: j.brennan@northstar.example
  givenName: Joseph
  familyName: Brennan
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: penelope.cross
spec:
  email: p.cross@northstar.example
  givenName: Penelope
  familyName: Cross
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: carter.wolfe
spec:
  email: c.wolfe@northstar.example
  givenName: Carter
  familyName: Wolfe
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: riley.snow
spec:
  email: r.snow@northstar.example
  givenName: Riley
  familyName: Snow
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: wyatt.ellison
spec:
  email: w.ellison@foxhollow.example
  givenName: Wyatt
  familyName: Ellison
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: zoey.garner
spec:
  email: z.garner@foxhollow.example
  givenName: Zoey
  familyName: Garner
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: john.blackwood
spec:
  email: j.blackwood@foxhollow.example
  givenName: John
  familyName: Blackwood
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: nora.sterling
spec:
  email: n.sterling@foxhollow.example
  givenName: Nora
  familyName: Sterling
---
apiVersion: iam.miloapis.com/v1alpha1
kind: User
metadata:
  name: aiden.cross
spec:
  email: a.cross@foxhollow.example
  givenName: Aiden
  familyName: Cross
EOF

# Grant all authenticated users access to their own User record and their
# OrganizationMemberships. Both portals need these immediately after login.
$KUBECTL_MILO apply --validate=false -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: milo-authenticated-user
rules:
  - apiGroups: ["iam.miloapis.com"]
    resources: ["users", "userinvitations"]
    verbs: ["get", "list"]
  - apiGroups: ["resourcemanager.miloapis.com"]
    resources: ["organizations", "projects", "organizationmemberships"]
    verbs: ["get", "list"]
  - apiGroups: ["support.miloapis.com"]
    resources: ["supporttickets"]
    verbs: ["get", "list", "create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: milo-authenticated-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: milo-authenticated-user
subjects:
  - kind: Group
    name: system:authenticated
    apiGroup: rbac.authorization.k8s.io
EOF

# Grant staff portal users access to dashboard resources: user list, orgs, projects,
# fraud evaluations (the dashboard shows counts of all four).
$KUBECTL_MILO apply --validate=false -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: milo-staff-user
rules:
  - apiGroups: ["iam.miloapis.com"]
    resources: ["groupmemberships", "groups", "users", "userinvitations", "platforminvitations"]
    verbs: ["get", "list"]
  - apiGroups: ["resourcemanager.miloapis.com"]
    resources: ["organizations", "projects", "organizationmemberships"]
    verbs: ["get", "list"]
  - apiGroups: ["notification.miloapis.com"]
    resources: ["contacts", "contactgroups", "emails", "emailbroadcasts", "emailtemplates"]
    verbs: ["get", "list"]
  - apiGroups: ["support.miloapis.com"]
    resources: ["supporttickets", "supportmessages"]
    verbs: ["get", "list"]
  - apiGroups: ["quota.miloapis.com"]
    resources: ["allowancebuckets", "resourceclaims", "resourcegrants"]
    verbs: ["get", "list"]
  - apiGroups: ["fraud.miloapis.com"]
    resources: ["fraudevaluations", "fraudpolicies"]
    verbs: ["get", "list"]
  - apiGroups: ["activity.miloapis.com"]
    resources: ["auditlogqueries"]
    verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: milo-staff-user-demo
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: milo-staff-user
subjects:
  - kind: User
    name: demo
    apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: milo-staff-user-alice
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: milo-staff-user
subjects:
  - kind: User
    name: alice
    apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: milo-staff-user-bob
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: milo-staff-user
subjects:
  - kind: User
    name: bob
    apiGroup: rbac.authorization.k8s.io
EOF

# Create the staff group and add all datum.net users as members.
# Staff portal uses Kubernetes RBAC (ClusterRole on the Milo apiserver) to
# authorize groupmembership list calls, and then checks group membership to
# gate access to the private layout.
$KUBECTL_MILO apply --validate=false -f - <<'EOF'
apiVersion: iam.miloapis.com/v1alpha1
kind: Group
metadata:
  name: staff-users
  namespace: milo-system
spec: {}
---
apiVersion: iam.miloapis.com/v1alpha1
kind: GroupMembership
metadata:
  name: staff-users-demo
  namespace: milo-system
spec:
  groupRef:
    name: staff-users
    namespace: milo-system
  userRef:
    name: demo
---
apiVersion: iam.miloapis.com/v1alpha1
kind: GroupMembership
metadata:
  name: staff-users-alice
  namespace: milo-system
spec:
  groupRef:
    name: staff-users
    namespace: milo-system
  userRef:
    name: alice
---
apiVersion: iam.miloapis.com/v1alpha1
kind: GroupMembership
metadata:
  name: staff-users-bob
  namespace: milo-system
spec:
  groupRef:
    name: staff-users
    namespace: milo-system
  userRef:
    name: bob
EOF

# Seed all customer organizations from the demo Dex config
$KUBECTL_MILO apply --validate=false -f - <<'EOF'
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: acme-corp
  annotations:
    kubernetes.io/display-name: "Acme Corp"
spec:
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: brightpath
  annotations:
    kubernetes.io/display-name: "Brightpath"
spec:
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: meridian-tech
  annotations:
    kubernetes.io/display-name: "Meridian Tech"
spec:
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: cascade-analytics
  annotations:
    kubernetes.io/display-name: "Cascade Analytics"
spec:
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: vertex-systems
  annotations:
    kubernetes.io/display-name: "Vertex Systems"
spec:
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: harbor-cloud
  annotations:
    kubernetes.io/display-name: "Harbor Cloud"
spec:
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: pinnacle
  annotations:
    kubernetes.io/display-name: "Pinnacle"
spec:
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: ridgeline
  annotations:
    kubernetes.io/display-name: "Ridgeline"
spec:
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: northstar
  annotations:
    kubernetes.io/display-name: "Northstar"
spec:
  type: Standard
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: Organization
metadata:
  name: foxhollow
  annotations:
    kubernetes.io/display-name: "Foxhollow"
spec:
  type: Standard
EOF

# Seed OrganizationMemberships so cloud portal users see their organization on login.
# The namespace for each membership is organization-<org-name>, created by the
# Milo controller when the Organization resource is provisioned.
$KUBECTL_MILO apply --validate=false -f - <<'EOF'
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: james-hartwell
  namespace: organization-acme-corp
spec:
  organizationRef:
    name: acme-corp
  userRef:
    name: james.hartwell
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: emma-sutton
  namespace: organization-acme-corp
spec:
  organizationRef:
    name: acme-corp
  userRef:
    name: emma.sutton
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: oliver-crane
  namespace: organization-acme-corp
spec:
  organizationRef:
    name: acme-corp
  userRef:
    name: oliver.crane
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: sophia-morales
  namespace: organization-acme-corp
spec:
  organizationRef:
    name: acme-corp
  userRef:
    name: sophia.morales
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: william-ford
  namespace: organization-acme-corp
spec:
  organizationRef:
    name: acme-corp
  userRef:
    name: william.ford
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: ava-chen
  namespace: organization-brightpath
spec:
  organizationRef:
    name: brightpath
  userRef:
    name: ava.chen
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: noah-patel
  namespace: organization-brightpath
spec:
  organizationRef:
    name: brightpath
  userRef:
    name: noah.patel
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: isabella-ross
  namespace: organization-brightpath
spec:
  organizationRef:
    name: brightpath
  userRef:
    name: isabella.ross
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: liam-warner
  namespace: organization-brightpath
spec:
  organizationRef:
    name: brightpath
  userRef:
    name: liam.warner
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: mia-kowalski
  namespace: organization-brightpath
spec:
  organizationRef:
    name: brightpath
  userRef:
    name: mia.kowalski
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: benjamin-shaw
  namespace: organization-meridian-tech
spec:
  organizationRef:
    name: meridian-tech
  userRef:
    name: benjamin.shaw
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: charlotte-tran
  namespace: organization-meridian-tech
spec:
  organizationRef:
    name: meridian-tech
  userRef:
    name: charlotte.tran
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: lucas-osei
  namespace: organization-meridian-tech
spec:
  organizationRef:
    name: meridian-tech
  userRef:
    name: lucas.osei
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: amelia-byrne
  namespace: organization-meridian-tech
spec:
  organizationRef:
    name: meridian-tech
  userRef:
    name: amelia.byrne
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: mason-lin
  namespace: organization-meridian-tech
spec:
  organizationRef:
    name: meridian-tech
  userRef:
    name: mason.lin
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: harper-nkosi
  namespace: organization-cascade-analytics
spec:
  organizationRef:
    name: cascade-analytics
  userRef:
    name: harper.nkosi
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: ethan-vasquez
  namespace: organization-cascade-analytics
spec:
  organizationRef:
    name: cascade-analytics
  userRef:
    name: ethan.vasquez
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: evelyn-price
  namespace: organization-cascade-analytics
spec:
  organizationRef:
    name: cascade-analytics
  userRef:
    name: evelyn.price
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: henry-dougherty
  namespace: organization-cascade-analytics
spec:
  organizationRef:
    name: cascade-analytics
  userRef:
    name: henry.dougherty
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: abigail-kim
  namespace: organization-cascade-analytics
spec:
  organizationRef:
    name: cascade-analytics
  userRef:
    name: abigail.kim
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: scarlett-novak
  namespace: organization-pinnacle
spec:
  organizationRef:
    name: pinnacle
  userRef:
    name: scarlett.novak
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: aiden-walsh
  namespace: organization-pinnacle
spec:
  organizationRef:
    name: pinnacle
  userRef:
    name: aiden.walsh
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: victoria-lane
  namespace: organization-pinnacle
spec:
  organizationRef:
    name: pinnacle
  userRef:
    name: victoria.lane
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: jack-obrien
  namespace: organization-pinnacle
spec:
  organizationRef:
    name: pinnacle
  userRef:
    name: jack.obrien
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: madison-frost
  namespace: organization-pinnacle
spec:
  organizationRef:
    name: pinnacle
  userRef:
    name: madison.frost
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: owen-callahan
  namespace: organization-ridgeline
spec:
  organizationRef:
    name: ridgeline
  userRef:
    name: owen.callahan
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: luna-espinoza
  namespace: organization-ridgeline
spec:
  organizationRef:
    name: ridgeline
  userRef:
    name: luna.espinoza
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: samuel-west
  namespace: organization-ridgeline
spec:
  organizationRef:
    name: ridgeline
  userRef:
    name: samuel.west
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: grace-mackenzie
  namespace: organization-ridgeline
spec:
  organizationRef:
    name: ridgeline
  userRef:
    name: grace.mackenzie
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: david-yuen
  namespace: organization-ridgeline
spec:
  organizationRef:
    name: ridgeline
  userRef:
    name: david.yuen
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: chloe-ingram
  namespace: organization-northstar
spec:
  organizationRef:
    name: northstar
  userRef:
    name: chloe.ingram
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: joseph-brennan
  namespace: organization-northstar
spec:
  organizationRef:
    name: northstar
  userRef:
    name: joseph.brennan
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: penelope-cross
  namespace: organization-northstar
spec:
  organizationRef:
    name: northstar
  userRef:
    name: penelope.cross
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: carter-wolfe
  namespace: organization-northstar
spec:
  organizationRef:
    name: northstar
  userRef:
    name: carter.wolfe
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: riley-snow
  namespace: organization-northstar
spec:
  organizationRef:
    name: northstar
  userRef:
    name: riley.snow
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: wyatt-ellison
  namespace: organization-foxhollow
spec:
  organizationRef:
    name: foxhollow
  userRef:
    name: wyatt.ellison
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: zoey-garner
  namespace: organization-foxhollow
spec:
  organizationRef:
    name: foxhollow
  userRef:
    name: zoey.garner
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: john-blackwood
  namespace: organization-foxhollow
spec:
  organizationRef:
    name: foxhollow
  userRef:
    name: john.blackwood
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: nora-sterling
  namespace: organization-foxhollow
spec:
  organizationRef:
    name: foxhollow
  userRef:
    name: nora.sterling
---
apiVersion: resourcemanager.miloapis.com/v1alpha1
kind: OrganizationMembership
metadata:
  name: aiden-cross
  namespace: organization-foxhollow
spec:
  organizationRef:
    name: foxhollow
  userRef:
    name: aiden.cross
EOF

echo "Milo users and organizations seeded"
