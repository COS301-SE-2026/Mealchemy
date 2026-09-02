
// --- creates santizied k6 output ---
// removes setup_data which may contain the login token.
// writes JSON to NFR_SUMMARY_PATH
// records checks, request count, throughput, p95 latency, failures, and auth failures.
// used by performace/non-recommendation-load and security/authorization-matrix

export function createSafeSummary(data) {
  const outputPath = __ENV.NFR_SUMMARY_PATH;
  const safeData = { ...data };
  delete safeData.setup_data;

  const output = {
    stdout: `${renderConsoleSummary(safeData)}\n`,
  };

  if (outputPath) {
    output[outputPath] = `${JSON.stringify(safeData, null, 2)}\n`;
  }

  return output;
}

function renderConsoleSummary(data) {
  const checks = values(data.metrics?.checks);
  const requests = values(data.metrics?.http_reqs);
  const duration = values(
    data.metrics?.['http_req_duration{measured:true}'] ||
      data.metrics?.http_req_duration,
  );
  const failures = values(
    data.metrics?.['http_req_failed{measured:true}'] ||
      data.metrics?.http_req_failed,
  );
  const authorizationFailures = values(
    data.metrics?.authorization_failures,
  );

  return [
    'NFR SAFE SUMMARY',
    `checks passed: ${formatNumber(checks.passes)}`,
    `checks failed: ${formatNumber(checks.fails)}`,
    `HTTP requests: ${formatNumber(requests.count)}`,
    `HTTP request rate: ${formatNumber(requests.rate)}/s`,
    `p95 duration: ${formatNumber(duration['p(95)'])} ms`,
    `HTTP failure rate: ${formatNumber(failures.rate ?? failures.value)}`,
    authorizationFailures.count === undefined
      ? null
        : `authorization failures: ${formatNumber(authorizationFailures.count)}`,
    outputPath
      ? `sanitized evidence: ${outputPath}`
      : 'sanitized evidence: not written (set NFR_SUMMARY_PATH)',
  ]
    .filter((line) => line !== null)
    .join('\n');
}

function values(metric) {
  return metric?.values || metric || {};
}

function formatNumber(value) {
  if (typeof value !== 'number') {
    return 'n/a';
  }
  return String(Math.round(value * 1000) / 1000);
}
