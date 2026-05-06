import { test, expect } from '@playwright/test';

const CLOUD_URL = 'https://cloud.localhost:30443';
const STAFF_URL = 'https://staff.localhost:30443';
const INCIDENTS_URL = 'https://incidents.localhost:30443';

// Cloud portal: a customer org user
const CLOUD_USER = 'james.hartwell@acme-corp.example';
const CLOUD_PASS = 'password';

// Staff portal: an internal datum.net user
const STAFF_USER = 'alice@datum.net';
const STAFF_PASS = 'password';

async function loginViaDex(page: any, portalURL: string, email: string, password: string) {
  await page.goto(portalURL);
  await page.waitForURL(/dex|auth|login/);
  await page.fill('[name=login]', email);
  await page.fill('[name=password]', password);
  await page.click('[type=submit]');
}

// ── Cloud portal ──────────────────────────────────────────────────────────────

test('cloud portal redirects to login', async ({ page }) => {
  await page.goto(CLOUD_URL);
  await expect(page).toHaveURL(/dex|auth|login/);
});

test('cloud portal login as customer user', async ({ page }) => {
  await loginViaDex(page, CLOUD_URL, CLOUD_USER, CLOUD_PASS);
  await expect(page.locator('header')).toBeVisible({ timeout: 15000 });
  await expect(page).not.toHaveURL(/error/);
  await expect(page.locator('body')).toContainText('James Hartwell', { timeout: 5000 });
});

test('cloud user can create a support ticket via API proxy', async ({ page }) => {
  await loginViaDex(page, CLOUD_URL, CLOUD_USER, CLOUD_PASS);
  await expect(page.locator('header')).toBeVisible({ timeout: 15000 });

  // Use the cloud portal's authenticated API proxy to create a support ticket
  const ticketName = `test-ticket-${Date.now()}`;
  const response = await page.evaluate(async ({ name }: { name: string }) => {
    const res = await fetch('/api/proxy/apis/support.miloapis.com/v1alpha1/supporttickets', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        apiVersion: 'support.miloapis.com/v1alpha1',
        kind: 'SupportTicket',
        metadata: { name },
        spec: {
          title: 'Playwright demo verification ticket',
          description: 'Created by automated demo verification.',
          priority: 'low',
          visibility: 'all-staff',
          organizationRef: { kind: 'Organization', name: 'acme-corp' },
          reporterRef: { name: 'james.hartwell' },
        },
      }),
    });
    return { status: res.status, ok: res.ok };
  }, { name: ticketName });

  expect(response.ok, `Expected 2xx but got ${response.status}`).toBe(true);
});

// ── Staff portal ──────────────────────────────────────────────────────────────

test('staff portal redirects to login', async ({ page }) => {
  await page.goto(STAFF_URL);
  await expect(page).toHaveURL(/dex|auth|login/);
});

test('staff portal login as staff user', async ({ page }) => {
  await loginViaDex(page, STAFF_URL, STAFF_USER, STAFF_PASS);
  await expect(page.locator('header')).toBeVisible({ timeout: 15000 });
  await expect(page).not.toHaveURL(/error/);
  await expect(page.locator('body')).toContainText('Alice', { timeout: 5000 });
});

test('staff user can view incidents via incidents UI', async ({ page }) => {
  // The incidents-ui is a standalone app proxied through the Envoy Gateway.
  // It uses the static test-admin-token so all authenticated staff can see incidents.
  await page.goto(INCIDENTS_URL);
  await page.waitForTimeout(3000);

  await expect(page.locator('header')).toBeVisible({ timeout: 10000 });
  // At least the 3 seeded incidents should be listed
  await expect(page.locator('body')).toContainText('Database latency spike', { timeout: 5000 });
  await expect(page.locator('body')).toContainText('CDN degraded performance', { timeout: 5000 });
});
