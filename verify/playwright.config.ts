import { defineConfig } from '@playwright/test';

const chromiumExecutablePath = process.env.CHROMIUM_EXECUTABLE_PATH ||
  '/nix/store/68h63fg3qyv62lkvmqpkdk8g8qnldzhp-chromium-147.0.7727.137/bin/chromium';

export default defineConfig({
  testDir: './tests',
  use: {
    baseURL: 'https://cloud.localhost:30443',
    ignoreHTTPSErrors: true,
    launchOptions: {
      executablePath: chromiumExecutablePath,
    },
  },
});
