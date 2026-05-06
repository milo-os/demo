import { defineConfig } from '@playwright/test';
import { execSync } from 'child_process';

function findChromium(): string {
  if (process.env.CHROMIUM_EXECUTABLE_PATH) {
    return process.env.CHROMIUM_EXECUTABLE_PATH;
  }
  // In nix develop, chromium is on PATH
  try {
    return execSync('which chromium', { encoding: 'utf8' }).trim();
  } catch {
    // Fallback: hardcoded nix store path for local dev
    return '/nix/store/68h63fg3qyv62lkvmqpkdk8g8qnldzhp-chromium-147.0.7727.137/bin/chromium';
  }
}

export default defineConfig({
  testDir: './tests',
  reporter: [['list'], ['html', { open: 'never', outputFolder: 'test-results/html' }]],
  use: {
    baseURL: 'https://cloud.localhost:30443',
    ignoreHTTPSErrors: true,
    launchOptions: {
      executablePath: findChromium(),
      args: ['--disable-crashpad', '--no-sandbox', '--disable-dev-shm-usage'],
    },
  },
});
