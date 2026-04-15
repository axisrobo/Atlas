// config/test.config.ts
export const testConfig = {
  baseUrl: process.env.UAT_BASE_URL 
    ?? 'https://eam.t-sy-in.earth.xcloud.lenovo.com/',
  diagrams: {
    appDiagram:  'test-data/ea-request/app-diagram/app.png',
    techDiagram: 'test-data/ea-request/tech-diagram/tech.png',
  },
  sso: {
    pollIntervalMs: 5000,
    maxWaitMs:      300000,   // 5 分钟超时
    detectionSelector: 'text="Log Out"',
  },
  audit: {
    logPath: 'test-results/ea-ids.log',
    requestIdPattern: /^REQ-\d+$/,
  },
};