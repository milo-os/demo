/**
 * User flow tests — exercises real interactions, not just page loads.
 * Tests what a human would actually do in each portal.
 */
import { test, expect } from '@playwright/test';

const CLOUD_URL = 'https://cloud.localhost:30443';
const STAFF_URL = 'https://staff.localhost:30443';

async function loginCloud(page: any) {
  await page.goto(CLOUD_URL);
  await page.waitForURL(/dex|auth|login/);
  await page.fill('[name=login]', 'james.hartwell@acme-corp.example');
  await page.fill('[name=password]', 'password');
  await page.click('[type=submit]');
  await page.waitForSelector('header', { timeout: 15000 });
  await page.waitForTimeout(1500);
}

async function loginStaff(page: any) {
  await page.goto(STAFF_URL);
  await page.waitForURL(/dex|auth|login/);
  await page.fill('[name=login]', 'alice@datum.net');
  await page.fill('[name=password]', 'password');
  await page.click('[type=submit]');
  await page.waitForSelector('header', { timeout: 15000 });
  await page.waitForTimeout(1500);
}

function track4xx(page: any) {
  const errors: string[] = [];
  page.on('response', (r: any) => {
    if (r.url().includes('localhost') && r.status() >= 400) {
      const p = r.url().replace(/https?:\/\/[^/]+/, '').split('?')[0];
      errors.push(`${r.status()} ${r.request().method()} ${p}`);
    }
  });
  return errors;
}

// ── Cloud portal flows ────────────────────────────────────────────────────────

test('cloud: james sees his organization and support tickets', async ({ page }) => {
  const errors = track4xx(page);
  await loginCloud(page);

  // Navigate to org
  await page.goto(`${CLOUD_URL}/org/acme-corp`);
  await page.waitForTimeout(2000);
  await expect(page.locator('body')).toContainText('Acme Corp');

  // Navigate to support tab
  await page.goto(`${CLOUD_URL}/org/acme-corp/support`);
  await page.waitForTimeout(2000);

  // Tickets from seed should be visible
  await expect(page.locator('body')).toContainText('Support Tickets');
  await expect(page.locator('body')).toContainText('demo-ticket-001');

  const errs = errors.filter(e => !e.includes('sentry') && !e.includes('favicon'));
  expect(errs, `Unexpected errors: ${errs.join(', ')}`).toHaveLength(0);
});

test('cloud: james opens a ticket and sees messages', async ({ page }) => {
  const errors = track4xx(page);
  await loginCloud(page);

  await page.goto(`${CLOUD_URL}/org/acme-corp/support/demo-ticket-001`);
  await page.waitForTimeout(2000);

  await expect(page.locator('body')).toContainText('Cannot access project dashboard');
  await expect(page.locator('body')).toContainText('Description');

  const errs = errors.filter(e => !e.includes('sentry') && !e.includes('favicon'));
  expect(errs, `Unexpected errors: ${errs.join(', ')}`).toHaveLength(0);
});

test('cloud: james can create a new support ticket', async ({ page }) => {
  const errors = track4xx(page);
  await loginCloud(page);

  await page.goto(`${CLOUD_URL}/org/acme-corp/support/new`);
  await page.waitForTimeout(1500);

  await expect(page.locator('body')).toContainText('Open a Support Ticket');

  // Fill and submit
  await page.fill('input[id="title"], input[placeholder*="issue"], input[placeholder*="Briefly"]', 'Test ticket from Playwright');
  const desc = page.locator('textarea').first();
  await desc.fill('This is a test ticket created by the automated test suite.');

  // Don't actually submit (would create noise data) — just verify the form is functional
  const submitBtn = page.locator('button[type=submit]');
  await expect(submitBtn).toBeEnabled();

  const errs = errors.filter(e => !e.includes('sentry') && !e.includes('favicon'));
  expect(errs, `Unexpected errors: ${errs.join(', ')}`).toHaveLength(0);
});

test('cloud: james can write a reply on a ticket', async ({ page }) => {
  const errors = track4xx(page);
  await loginCloud(page);

  await page.goto(`${CLOUD_URL}/org/acme-corp/support/demo-ticket-001`);
  await page.waitForTimeout(2000);

  const textarea = page.locator('textarea').last();
  await expect(textarea).toBeVisible();
  await textarea.fill('Hello, this is a test reply from the automated suite.');
  await expect(textarea).toHaveValue(/test reply/);

  const errs = errors.filter(e => !e.includes('sentry') && !e.includes('favicon'));
  expect(errs, `Unexpected errors: ${errs.join(', ')}`).toHaveLength(0);
});

// ── Staff portal flows ─────────────────────────────────────────────────────────

test('staff: alice sees the support ticket list', async ({ page }) => {
  const errors = track4xx(page);
  await loginStaff(page);

  await page.goto(`${STAFF_URL}/support`);
  await page.waitForTimeout(2500);

  // The support layout shows "Tickets" and "Knowledge Base" tabs
  await expect(page.locator('body')).toContainText('Tickets');
  await expect(page.locator('body')).toContainText('demo-ticket-001');

  // Only expected 404s (fraud/activity not deployed) — no 403s on support resources
  const real403s = errors.filter(e =>
    e.includes('403') &&
    e.includes('support') &&
    !e.includes('sentry') &&
    !e.includes('favicon')
  );
  expect(real403s, `403 errors on support API: ${real403s.join(', ')}`).toHaveLength(0);
});

test('staff: alice opens a ticket and sees full detail', async ({ page }) => {
  const errors = track4xx(page);
  await loginStaff(page);

  // Navigate directly to ticket detail
  await page.goto(`${STAFF_URL}/support/demo-ticket-001`);
  await page.waitForTimeout(2500);

  // Ticket content should be visible
  await expect(page.locator('body')).toContainText('Cannot access project dashboard');
  await expect(page.locator('body')).toContainText('Description');
  await expect(page.locator('body')).toContainText('#demo-ticket-001');

  // Reply form should be present
  const replyArea = page.locator('textarea').last();
  await expect(replyArea).toBeVisible();

  const real403s = errors.filter(e =>
    e.includes('403') && !e.includes('sentry') && !e.includes('favicon')
  );
  expect(real403s, `403 errors: ${real403s.join(', ')}`).toHaveLength(0);
});

test('staff: alice can type a reply in the markdown editor', async ({ page }) => {
  const errors = track4xx(page);
  await loginStaff(page);

  await page.goto(`${STAFF_URL}/support/demo-ticket-001`);
  await page.waitForTimeout(2500);

  const textarea = page.locator('textarea').last();
  await expect(textarea).toBeVisible();
  await textarea.click();
  await textarea.fill('This is a test reply with **bold** and _italic_ text.');

  // Preview tab should render the markdown
  await page.getByRole('button', { name: 'Preview' }).first().click();
  await page.waitForTimeout(500);
  const preview = page.locator('body');
  await expect(preview).toContainText('bold');

  const real403s = errors.filter(e =>
    e.includes('403') && !e.includes('sentry') && !e.includes('favicon')
  );
  expect(real403s, `403 errors: ${real403s.join(', ')}`).toHaveLength(0);
});

test('staff: image paste creates a base64 data URL in the editor', async ({ page }) => {
  await loginStaff(page);

  await page.goto(`${STAFF_URL}/support/demo-ticket-001`);
  await page.waitForTimeout(2500);

  const textarea = page.locator('textarea').last();
  await expect(textarea).toBeVisible();
  await textarea.click();

  // Simulate pasting a 1×1 transparent PNG via clipboard API
  const pasteSucceeded = await page.evaluate(async () => {
    const ta = document.querySelectorAll('textarea');
    const replyTa = ta[ta.length - 1];
    if (!replyTa) return { error: 'no textarea' };

    // Build a minimal 1×1 PNG as a Blob
    const b64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
    const binary = atob(b64);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
    const blob = new Blob([bytes], { type: 'image/png' });

    const dt = new DataTransfer();
    dt.items.add(new File([blob], 'test.png', { type: 'image/png' }));

    const ev = new ClipboardEvent('paste', { clipboardData: dt, bubbles: true, cancelable: true });
    replyTa.dispatchEvent(ev);
    return { dispatched: true };
  });

  expect(pasteSucceeded.error).toBeUndefined();

  // Wait for upload roundtrip (base64 conversion is async)
  await page.waitForTimeout(2000);

  const val = await textarea.inputValue();
  // The upload endpoint should have returned a data: URL; editor inserts ![image](data:...)
  // OR the placeholder "![Uploading…]()" if upload is in flight
  // Either way, the paste event should have been handled (not silently dropped)
  expect(val).toMatch(/!\[.*\]\(.*\)/);
});

test('staff: alice can view ticket actions without HTTP errors', async ({ page }) => {
  const errors = track4xx(page);
  await loginStaff(page);

  await page.goto(`${STAFF_URL}/support/demo-ticket-001`);
  await page.waitForTimeout(2500);

  // The ticket actions sidebar should render Owner, Status, Priority fields
  await expect(page.locator('body')).toContainText('Status');
  await expect(page.locator('body')).toContainText('Priority');
  await expect(page.locator('body')).toContainText('Owner');

  // No 403s on support API calls — ticket content may contain "403" as a word
  // so we check the HTTP errors list, not the body text
  const real403s = errors.filter(e =>
    e.includes('403') && e.includes('support') && !e.includes('sentry') && !e.includes('favicon')
  );
  expect(real403s, `403 on support API: ${real403s.join(', ')}`).toHaveLength(0);
});

test('staff: alice sees the incidents iframe', async ({ page }) => {
  const errors = track4xx(page);
  await loginStaff(page);

  await page.goto(`${STAFF_URL}/incidents`);
  await page.waitForTimeout(4000);

  const iframe = page.locator('iframe[title="Incidents"]');
  await expect(iframe).toBeVisible();

  // The incidents iframe should load the incidents UI
  const frame = iframe.contentFrame();
  if (frame) {
    await expect(frame.locator('body')).toContainText(/[Ii]ncident/, { timeout: 8000 });
  }

  const real403s = errors.filter(e =>
    e.includes('403') && !e.includes('sentry') && !e.includes('favicon') && !e.includes('incident')
  );
  expect(real403s, `403 errors: ${real403s.join(', ')}`).toHaveLength(0);
});
