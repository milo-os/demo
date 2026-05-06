import { test, expect } from '@playwright/test';

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

test('staff portal sidebar shows Support and Incidents with real labels', async ({ page }) => {
  await loginViaDex(page, STAFF_URL, 'alice@datum.net', 'password');

  const sidebar = page.locator('[data-sidebar="menu-button"], [data-sidebar="menu-sub-button"]');
  const texts = await sidebar.allTextContents();
  const allText = texts.join(' ');

  console.log('Sidebar nav items:', texts.filter(t => t.trim()));

  // The new nav items should show real words, not hash IDs
  expect(allText).toContain('Support');
  expect(allText).toContain('Incidents');

  // The original known hash strings should not appear anywhere
  expect(allText).not.toContain('XYLcNv');
  expect(allText).not.toContain('JN4pgo');
});

test('staff support page renders real English text', async ({ page }) => {
  await loginViaDex(page, STAFF_URL, 'alice@datum.net', 'password');
  await page.goto(`${STAFF_URL}/support`);
  await page.waitForTimeout(3000);

  const visible = (await page.locator('body').innerText()).replace(/\s+/g, ' ').slice(0, 600);
  console.log('Support page body:', visible);

  expect(visible).toContain('Support Tickets');
  expect(visible).not.toContain('XYLcNv');
  expect(visible).not.toContain('JN4pgo');
});

test('staff incidents page embeds incidents UI', async ({ page }) => {
  await loginViaDex(page, STAFF_URL, 'alice@datum.net', 'password');
  await page.goto(`${STAFF_URL}/incidents`);
  await page.waitForTimeout(4000);

  // The iframe should be present
  const iframe = page.locator('iframe[title="Incidents"]');
  await expect(iframe).toBeVisible({ timeout: 10000 });

  // The outer page should not show hash IDs
  const body = await page.locator('body').textContent() || '';
  expect(body).not.toContain('XYLcNv');
  expect(body).not.toContain('JN4pgo');
});
