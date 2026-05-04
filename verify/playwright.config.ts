import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  use: {
    baseURL: 'https://cloud.localhost:30443',
    ignoreHTTPSErrors: true,
  },
});
