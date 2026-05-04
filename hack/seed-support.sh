#!/usr/bin/env bash
set -euo pipefail
echo "Seeding support tickets..."

kubectl apply -f - <<'EOF'
apiVersion: support.miloapis.com/v1alpha1
kind: SupportTicket
metadata:
  name: demo-ticket-001
spec:
  title: "Cannot access project dashboard"
  description: |
    Getting 403 Forbidden errors when navigating to the project dashboard.
    This started happening after I updated my organization settings yesterday.
    Steps to reproduce:
    1. Log into cloud portal
    2. Navigate to any project
    3. Observe 403 error
  status: open
  priority: high
  visibility: all-staff
  organizationRef:
    kind: Organization
    name: acme-corp
  reporterRef:
    name: jane-doe
    displayName: "Jane Doe"
    email: jane@acme-corp.example
  tags:
    - access
    - dashboard
---
apiVersion: support.miloapis.com/v1alpha1
kind: SupportTicket
metadata:
  name: demo-ticket-002
spec:
  title: "Billing invoice shows incorrect amount"
  description: |
    Our last invoice shows charges for resources we decommissioned last month.
    The extra charges amount to approximately $240 USD.
  status: in-progress
  priority: medium
  visibility: all-staff
  organizationRef:
    kind: Organization
    name: acme-corp
  reporterRef:
    name: bob-smith
    displayName: "Bob Smith"
    email: bob@acme-corp.example
  ownerRef:
    name: alice-support
    displayName: "Alice (Support)"
    email: alice@datum.net
  tags:
    - billing
    - invoicing
---
apiVersion: support.miloapis.com/v1alpha1
kind: SupportTicket
metadata:
  name: demo-ticket-003
spec:
  title: "API rate limit errors on bulk export"
  description: |
    Our automation is hitting 429 Too Many Requests when running nightly bulk exports.
    This is blocking our data pipeline. Can we get a rate limit increase or guidance
    on batching requests?
  status: waiting-on-customer
  priority: low
  visibility: all-staff
  organizationRef:
    kind: Organization
    name: widget-co
  reporterRef:
    name: charlie-ops
    displayName: "Charlie (Ops)"
    email: charlie@widget-co.example
  tags:
    - api
    - rate-limit
EOF

echo "Seeding support messages..."

kubectl apply -f - <<'EOF'
apiVersion: support.miloapis.com/v1alpha1
kind: SupportMessage
metadata:
  name: demo-msg-001
spec:
  ticketRef: demo-ticket-001
  body: |
    Hi Jane,

    Thanks for reaching out! I've reproduced the 403 error on our end. This appears
    to be related to a permissions migration we ran last night. I'm working on a fix
    now and will update you shortly.

    Best,
    Alice (Support Team)
  authorRef:
    name: alice-support
    displayName: "Alice (Support)"
    email: alice@datum.net
  authorType: staff
  internal: false
---
apiVersion: support.miloapis.com/v1alpha1
kind: SupportMessage
metadata:
  name: demo-msg-002
spec:
  ticketRef: demo-ticket-001
  body: |
    Internal note: Caused by the org-settings migration script not backfilling
    project-level permissions. Tracked in INFRA-4521. ETA: 2 hours.
  authorRef:
    name: alice-support
    displayName: "Alice (Support)"
    email: alice@datum.net
  authorType: staff
  internal: true
EOF

echo "Support tickets and messages seeded"
