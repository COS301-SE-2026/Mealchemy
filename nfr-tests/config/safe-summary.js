
// --- creates santizied k6 output ---
// removes setup_data which may contain the login token.
// writes JSON to NFR_SUMMARY_PATH
// records checks, request count, throughput, p95 latency, failures, and auth failures.
// used by performace/non-recommendation-load and security/authorization-matrix

export function createSafeSummary(data) {
  const outputPath = __ENV.NFR_SUMMARY_PATH;
  const safeData = JSON.parse(JSON.stringify(data));
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
    `checks passed: ${number(checks.passes)}`,
    `checks failed: ${number(checks.fails)}`,
    `HTTP requests: ${number(requests.count)}`,
    `HTTP request rate: ${number(requests.rate)}/s`,
    `p95 duration: ${number(duration['p(95)'])} ms`,
    `HTTP failure rate: ${number(failures.rate ?? failures.value)}`,
    authorizationFailures.count === undefined
      ? null
      : `authorization failures: ${number(authorizationFailures.count)}`,
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

function number(value) {
  if (typeof value !== 'number') {
    return 'n/a';
  }
  return Math.round(value * 1000) / 1000;
}
