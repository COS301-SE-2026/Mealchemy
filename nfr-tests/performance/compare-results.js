// --------  BASELINE AND PEAK COMPARISON ------
// compares the two measuresd k6 evidence files
// script provides an executable comparison between baseline nad peak to prove scaling behaviour
// reads 500 user 5 min baseline and 1000 user 5 min peak.

/* checks:
  baseline p95 is at most two seconds
  peak p95 is at most 2s
  both error rates remain below 2s
  both error rates remain below 1%
  peak p95 increases by no more than 10%
*/
// ------------------------------------------------

const fs = require('node:fs');
const [baselinePath, peakPath] = process.argv.slice(2);

// exit code 2 - represents incorrect invoccation, not an NFR failure
if (!baselinePath || !peakPath) {
  console.error(
    'Usage: node compare-results.js <baseline-summary.json> <peak-summary.json>',
  );
  process.exit(2);
}

const baseline = readSummary(baselinePath);
const peak = readSummary(peakPath);

//calculates how much peak p95 latency increased relative to baseline
const latencyIncreasePercent =
  ((peak.p95Milliseconds - baseline.p95Milliseconds) /
    baseline.p95Milliseconds) *
  100;
const throughputRatio = peak.requestsPerSecond / baseline.requestsPerSecond;

// NFR Assertions
const checks = [
  result('baseline p95 <= 2000 ms', baseline.p95Milliseconds <= 2000),
  result('peak p95 <= 2000 ms', peak.p95Milliseconds <= 2000),
  result('baseline error rate < 1%', baseline.errorRate < 0.01),
  result('peak error rate < 1%', peak.errorRate < 0.01),
  result('peak p95 increase <= 10%', latencyIncreasePercent <= 10),
  result('peak throughput >= 1.8x baseline', throughputRatio >= 1.8),
];

// print JSON evidence
// overall sucess when every comparison check passes

console.log(
  JSON.stringify(
    {
      baseline,
      peak,
      latencyIncreasePercent: round(latencyIncreasePercent),
      throughputRatio: round(throughputRatio),
      checks,
      passed: checks.every((check) => check.passed),
    },
    null,
    2,
  ),
);

if (checks.some((check) => !check.passed)) {
  process.exitCode = 1;
}

// summary ready helper
function readSummary(path) {
  const summary = JSON.parse(fs.readFileSync(path, 'utf8'));
  const durationMetric = values(
    summary.metrics?.['http_req_duration{measured:true}'] ||
      summary.metrics?.http_req_duration,
  );
  const failureMetric = values(
    summary.metrics?.['http_req_failed{measured:true}'] ||
      summary.metrics?.http_req_failed,
  );
  const requestMetric = values(summary.metrics?.http_reqs);

  if (
    typeof durationMetric['p(95)'] !== 'number' ||
    typeof (failureMetric.rate ?? failureMetric.value) !== 'number' ||
    typeof requestMetric.rate !== 'number'
  ) {
    throw new TypeError(`${path} is not a valid k6 summary export.`);
  }

  return {
    path,
    p95Milliseconds: round(durationMetric['p(95)']),
    errorRate: round(failureMetric.rate ?? failureMetric.value),
    requestsPerSecond: round(requestMetric.rate),
  };
}

function values(metric) {
  return metric?.values || metric || {};
}

// assertion record
function result(name, passed) {
  return { name, passed };
}
// rounds to 3 decimal places
function round(value) {
  return Math.round(value * 1000) / 1000;
}
