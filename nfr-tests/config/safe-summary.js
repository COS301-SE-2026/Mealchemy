
// --- creates santizied k6 output ---
// removes setup_data which may contain the login token.
// writes JSON to NFR_SUMMARY_PATH
// records checks, request count, throughput, p95 latency, failures, and auth failures.
// used by performace/non-recommendation-load and security/authorization-matrix

export function createSafeSummary(data, evidence = {}) {
  const outputPath = __ENV.NFR_SUMMARY_PATH;
  const safeData = { ...data };
  delete safeData.setup_data;

  if (Object.keys(evidence).length > 0) {
    safeData.evidence = evidence;
  }

  const output = {
    stdout: `${renderConsoleSummary(safeData, outputPath)}\n`,
  };

  if (outputPath) {
    output[outputPath] = `${JSON.stringify(safeData, null, 2)}\n`;
  }

  return output;
}

function renderConsoleSummary(data, outputPath) {
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
  const endpointLines = renderEndpointMetrics(data.metrics);
  const evidence = data.evidence || {};

  return [
    'NFR SAFE SUMMARY',
    evidence.testProfile ? `test profile: ${evidence.testProfile}` : null,
    evidence.environment ? `environment: ${evidence.environment}` : null,
    evidence.virtualUsers === undefined
      ? null
      : `virtual users: ${evidence.virtualUsers}`,
    evidence.duration ? `duration: ${evidence.duration}` : null,
    `checks passed: ${formatNumber(checks.passes)}`,
    `checks failed: ${formatNumber(checks.fails)}`,
    `HTTP requests: ${formatNumber(requests.count)}`,
    `HTTP request rate: ${formatNumber(requests.rate)}/s`,
    `p95 duration: ${formatNumber(duration['p(95)'])} ms`,
    `HTTP failure rate: ${formatNumber(failures.rate ?? failures.value)}`,
    ...endpointLines,
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

function renderEndpointMetrics(metrics = {}) {
  const endpoints = [
    ['vaults', 'vaults'],
    ['pantry', 'pantry'],
    ['shopping_lists', 'shopping-lists'],
    ['recipes', 'recipes'],
    ['recipe_store', 'recipe-store'],
    ['recipe_retrieve', 'recipe-retrieve'],
  ];

  return endpoints.flatMap(([metricName, label]) => {
    const duration = values(metrics[`endpoint_${metricName}_duration`]);
    const failures = values(metrics[`endpoint_${metricName}_failed`]);

    if (duration['p(95)'] === undefined && failures.rate === undefined) {
      return [];
    }

    return [
      `${label} p95: ${formatNumber(duration['p(95)'])} ms; ` +
        `failure rate: ${formatNumber(failures.rate ?? failures.value)}`,
    ];
  });
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
