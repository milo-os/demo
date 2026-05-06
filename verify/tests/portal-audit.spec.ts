import { test } from '@playwright/test';
import { writeFileSync } from 'fs';

const CLOUD_URL = 'https://cloud.localhost:30443';
const STAFF_URL = 'https://staff.localhost:30443';

async function loginViaDex(page: any, url: string, email: string, password: string) {
  await page.goto(url);
  await page.waitForURL(/dex|auth|login/);
  await page.fill('[name=login]', email);
  await page.fill('[name=password]', password);
  await page.click('[type=submit]');
  await page.waitForSelector('header', { timeout: 15000 });
  await page.waitForTimeout(2000);
}

function trackErrors(page: any) {
  const errors = new Map<string, number>();
  page.on('response', (resp: any) => {
    if (resp.status() >= 400 && resp.url().includes('localhost')) {
      const path = resp.url().replace(/https?:\/\/[^/]+/, '').split('?')[0];
      const key = `${resp.status()} ${resp.request().method()} ${path}`;
      errors.set(key, (errors.get(key) || 0) + 1);
    }
  });
  return errors;
}

function bodySnippet(page: any) {
  return page.locator('body').textContent().then((t: string | null) =>
    (t || '').replace(/\s+/g, ' ').trim().slice(0, 400)
  );
}

test('staff full navigation audit', async ({ page }) => {
  const errors = trackErrors(page);
  await loginViaDex(page, STAFF_URL, 'alice@datum.net', 'password');

  // Routes discovered from the staff portal route files
  const routes: [string, string][] = [
    ['Dashboard',          '/'],
    ['Customers',          '/customers/users'],
    ['Contacts',           '/contacts'],
    ['Groups',             '/groups'],
    ['Email Activity',     '/email-activity'],
    ['Activity Hub',       '/activity-hub'],
    ['Fraud & Abuse',      '/fraud'],
    ['Users',              '/user'],
    ['Organizations',      '/organization'],
    ['Projects',           '/project'],
  ];

  const report: string[] = ['=== STAFF PORTAL NAVIGATION AUDIT ==='];
  for (const [label, path] of routes) {
    await page.goto(`${STAFF_URL}${path}`);
    await page.waitForTimeout(2500);
    const body = await bodySnippet(page);
    const hasError = body.includes('Something went wrong') || page.url().includes('error');
    report.push(`[${label}] ${page.url()}${hasError ? ' ⚠ ERROR' : ''}`);
    if (hasError) report.push(`  body: ${body.slice(0, 200)}`);
  }

  report.push('\n=== 4xx ERRORS ===');
  [...errors.entries()]
    .filter(([k]) => !k.includes('favicon') && !k.includes('sentry'))
    .sort(([a], [b]) => a.localeCompare(b))
    .forEach(([key, count]) => report.push(`  ${key} (x${count})`));

  writeFileSync('/tmp/staff-audit.txt', report.join('\n'));
});

test('cloud full navigation audit', async ({ page }) => {
  const errors = trackErrors(page);
  await loginViaDex(page, CLOUD_URL, 'james.hartwell@acme-corp.example', 'password');

  const report: string[] = ['=== CLOUD PORTAL NAVIGATION AUDIT ==='];

  // Orgs page
  report.push(`[orgs] ${page.url()}`);
  report.push(`  body: ${await bodySnippet(page)}`);

  // Click org card — cloud portal uses clickable divs/buttons, not just <a>
  const orgElement = page.locator('[data-discover], a, button').filter({ hasText: /Acme Corp/i }).first();
  if (await orgElement.isVisible({ timeout: 3000 })) {
    await orgElement.click();
    await page.waitForTimeout(3000);
    report.push(`[acme-corp detail] ${page.url()}`);
    report.push(`  body: ${await bodySnippet(page)}`);
  } else {
    report.push('[acme-corp] org card not clickable — checking URL navigation');
    // Try direct URL
    await page.goto(`${CLOUD_URL}/org/acme-corp`);
    await page.waitForTimeout(3000);
    report.push(`[/org/acme-corp] ${page.url()}`);
    report.push(`  body: ${await bodySnippet(page)}`);
  }

  report.push('\n=== 4xx ERRORS ===');
  [...errors.entries()]
    .filter(([k]) => !k.includes('favicon') && !k.includes('sentry'))
    .sort(([a], [b]) => a.localeCompare(b))
    .forEach(([key, count]) => report.push(`  ${key} (x${count})`));

  writeFileSync('/tmp/cloud-audit.txt', report.join('\n'));
});
