import { test, expect } from '@playwright/test';

test('cloud portal loads and redirects to login', async ({ page }) => {
  await page.goto('/');
  // Should redirect to Dex login
  await expect(page).toHaveURL(/dex|auth|login/);
});

test('cloud portal login flow', async ({ page }) => {
  await page.goto('/');
  await page.fill('[name=login]', 'demo@datum.net');
  await page.fill('[name=password]', 'password');
  await page.click('[type=submit]');
  // After login, should reach the portal
  await expect(page).not.toHaveURL(/login/);
});

test('incidents UI loads', async ({ page }) => {
  await page.goto('https://incidents.localhost:30443');
  await expect(page.locator('body')).toBeVisible();
});
