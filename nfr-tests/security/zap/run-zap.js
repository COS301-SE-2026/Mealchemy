
//  ------ Controls the complete ZAP scan -----------
// ZAP is a general purpose scanner, the runner gives it the correct scope, credentials, safety limits, evidence handling, and pass/fail bahvviour for system

/* what it does:
 downloads staging OpenApi.
 logs in with the disposable account.
 creates temp scan defintions and automation plans.
 satrts zap through docker.
 runs separate public and authenticated scans.
 sends the JWT through process environment rather than command arguments.
 evaluates the raw reports.
 writes safe evidence (no creds).
 deletes temp raw reports.
 */

//------------------------------------------------

const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const { prepareOpenApi } = require('./prepare-openapi');
const {
  evaluateReports,
  loadJson,
  redactSecrets,
  renderHtml,
} = require('./evaluate-zap-report');

const DEFAULT_IMAGE = 'ghcr.io/zaproxy/zaproxy:stable';
const RESULTS_DIR = path.resolve(__dirname, '../../..', 'results');
const ACCEPTED_FINDINGS_PATH = path.join(__dirname, 'accepted-findings.json');


// fetches OpenApi spec, logs in, prepares scan plans, reun public/auth scans, eval results, writes reports
async function main() {
  const config = readConfig();
  const temporaryDirectory = fs.mkdtempSync(
    path.join(os.tmpdir(), 'mealchemy-zap-'),
  );

  try {
    const [openApiDocument, token] = await Promise.all([
      fetchOpenApi(config.baseUrl),
      login(config),
    ]);
    const prepared = prepareOpenApi(openApiDocument, config.baseUrl);

    writeJson(
      path.join(temporaryDirectory, 'public-get-openapi.json'),
      prepared.publicDocument,
    );
    writeJson(
      path.join(temporaryDirectory, 'authenticated-get-openapi.json'),
      prepared.authenticatedDocument,
    );
    fs.writeFileSync(
      path.join(temporaryDirectory, 'public-plan.yaml'),
      automationPlan(config, 'public'),
    );
    fs.writeFileSync(
      path.join(temporaryDirectory, 'authenticated-plan.yaml'),
      automationPlan(config, 'authenticated'),
    );

    const publicRun = runZap({
      config,
      scope: 'public',
      temporaryDirectory,
      token: null,
    });
    const authenticatedRun = runZap({
      config,
      scope: 'authenticated',
      temporaryDirectory,
      token,
    });

    const reports = [
      {
        scope: 'public',
        report: loadRawReport(temporaryDirectory, 'public'),
      },
      {
        scope: 'authenticated',
        report: loadRawReport(temporaryDirectory, 'authenticated'),
      },
    ];
    const acceptedFindings = loadJson(ACCEPTED_FINDINGS_PATH);
    const evidence = evaluateReports({
      reports,
      acceptedFindings,
      manifest: prepared.manifest,
      image: config.image,
      scanRuns: [publicRun, authenticatedRun],
      secrets: [token, config.email, config.password],
    });

    fs.mkdirSync(RESULTS_DIR, { recursive: true });
    writeJson(path.join(RESULTS_DIR, 'zap-security-report.json'), evidence);
    fs.writeFileSync(
      path.join(RESULTS_DIR, 'zap-security-report.html'),
      renderHtml(evidence),
    );

    printResult(evidence);
    if (!evidence.passed) {
      process.exitCode = 1;
    }
  } finally {
    fs.rmSync(temporaryDirectory, { recursive: true, force: true });
  }
}


// reads and validates required env vars
function readConfig() {
  if (process.env.NFR_ENVIRONMENT !== 'staging') {
    throw new Error('ZAP active scans require NFR_ENVIRONMENT=staging.');
  }
  if (process.env.NFR_ZAP_ACTIVE_SCAN_ACK !== 'staging-only') {
    throw new Error(
      'Set NFR_ZAP_ACTIVE_SCAN_ACK=staging-only to acknowledge the active staging attack.',
    );
  }

  const baseUrl = required('STAGING_BASE_URL').replace(/\/+$/, '');
  const parsedUrl = new URL(baseUrl);
  if (parsedUrl.protocol !== 'https:') {
    throw new Error('ZAP staging scans require an HTTPS target.');
  }

  const confirmedHost = process.env.NFR_CONFIRMED_STAGING_HOST;
  if (
    !parsedUrl.hostname.toLowerCase().includes('staging') &&
    confirmedHost !== parsedUrl.hostname
  ) {
    throw new Error(
      'The target hostname does not contain "staging". Set NFR_CONFIRMED_STAGING_HOST to the exact staging hostname after verifying it.',
    );
  }

  if (process.env.PRODUCTION_BASE_URL) {
    const productionHost = new URL(process.env.PRODUCTION_BASE_URL).hostname;
    if (productionHost === parsedUrl.hostname) {
      throw new Error('Refusing to actively scan the production hostname.');
    }
  }

  return {
    baseUrl,
    hostname: parsedUrl.hostname,
    email: required('NFR_TEST_EMAIL'),
    password: required('NFR_TEST_PASSWORD'),
    image: process.env.ZAP_DOCKER_IMAGE || DEFAULT_IMAGE,
    maxScanMinutes: positiveInteger('ZAP_MAX_SCAN_MINUTES', 15),
    delayMs: positiveInteger('ZAP_DELAY_MS', 100),
  };
}
// fetch live OpenAPI from targets v3/api-docs endpoint
async function fetchOpenApi(baseUrl) {
  const response = await fetch(`${baseUrl}/v3/api-docs`, {
    headers: { Accept: 'application/json' },
  });
  if (!response.ok) {
    throw new Error(`Could not fetch staging OpenAPI (HTTP ${response.status}).`);
  }
  return response.json();
}

// logs into app with disposable test account and returns auth token
async function login(config) {
  const response = await fetch(`${config.baseUrl}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: config.email, password: config.password }),
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok || typeof body.token !== 'string' || !body.token) {
    throw new Error(
      `Could not authenticate the disposable ZAP account (HTTP ${response.status}).`,
    );
  }
  return body.token;
}

// spins up the ZAP Docker container, injects auth header env vars when token is provided
function runZap({ config, scope, temporaryDirectory, token }) {
  const environment = { ...process.env };
  delete environment.ZAP_AUTH_HEADER;
  delete environment.ZAP_AUTH_HEADER_VALUE;
  delete environment.ZAP_AUTH_HEADER_SITE;

  const args = ['run', '--rm'];
  if (token) {
    environment.ZAP_AUTH_HEADER = 'Authorization';
    environment.ZAP_AUTH_HEADER_VALUE = `Bearer ${token}`;
    environment.ZAP_AUTH_HEADER_SITE = config.hostname;
    args.push(
      '--env',
      'ZAP_AUTH_HEADER',
      '--env',
      'ZAP_AUTH_HEADER_VALUE',
      '--env',
      'ZAP_AUTH_HEADER_SITE',
    );
  }

  args.push(
    '--volume',
    `${temporaryDirectory}:/zap/wrk:rw`,
    config.image,
    'zap.sh',
    '-cmd',
    '-autorun',
    `/zap/wrk/${scope}-plan.yaml`,
  );

  process.stdout.write(`Starting ${scope} GET-only ZAP scan against staging.\n`);
  const result = spawnSync('docker', args, {
    env: environment,
    encoding: 'utf8',
    maxBuffer: 100 * 1024 * 1024,
  });
  const safeOutput = redactSecrets(
    `${result.stdout || ''}${result.stderr || ''}`,
    [token, config.email, config.password],
  );
  if (safeOutput.trim()) {
    process.stdout.write(`${safeOutput.trim()}\n`);
  }

  if (result.error) {
    throw new Error(`Could not start Docker for the ${scope} scan: ${result.error.message}`);
  }

  return {
    scope,
    exitCode: result.status ?? 1,
  };
}
// builds yaml zap automation framework for a given scope
function automationPlan(config, scope) {
  const contextName = `mealchemy-staging-${scope}-get`;
  const quotedUrl = JSON.stringify(config.baseUrl);

  return `env:
  contexts:
    - name: ${JSON.stringify(contextName)}
      urls:
        - ${quotedUrl}
      includePaths:
        - ${JSON.stringify(`${config.baseUrl}.*`)}
      excludePaths: []
  parameters:
    failOnError: true
    failOnWarning: false
    continueOnFailure: true

jobs:
  - type: openapi
    parameters:
      apiFile: /zap/wrk/${scope}-get-openapi.json
      context: ${JSON.stringify(contextName)}
      targetUrl: ${quotedUrl}

  - type: passiveScan-wait
    parameters:
      maxDuration: 5

  - type: activeScan
    parameters:
      context: ${JSON.stringify(contextName)}
      url: ${quotedUrl}
      defaultStrength: Low
      defaultThreshold: Low
      maxRuleDurationInMins: 2
      maxScanDurationInMins: ${config.maxScanMinutes}
      delayInMs: ${config.delayMs}
      threadPerHost: 2
      maxAlertsPerRule: 10
      scanHeadersAllRequests: true

  - type: passiveScan-wait
    parameters:
      maxDuration: 5

  - type: report
    parameters:
      template: traditional-json
      reportDir: /zap/wrk
      reportFile: raw-${scope}
      reportTitle: Mealchemy staging ${scope} GET-only ZAP scan
      displayReport: false
    risks:
      - high
      - medium
      - low
      - info
    confidences:
      - high
      - medium
      - low
      - falsepositive
`;
}

// locates and loads the single raw ZAP JSON report file produced
function loadRawReport(directory, scope) {
  const candidates = fs
    .readdirSync(directory)
    .filter((name) => name.startsWith(`raw-${scope}`) && name.endsWith('.json'));
  if (candidates.length !== 1) {
    throw new Error(
      `Expected one raw ${scope} ZAP JSON report, found ${candidates.length}.`,
    );
  }
  return loadJson(path.join(directory, candidates[0]));
}

// prints pass/fail summary with alert counts and paths to evidence files
function printResult(evidence) {
  process.stdout.write(
    [
      'ZAP SAFE SUMMARY',
      `status: ${evidence.passed ? 'PASS' : 'FAIL'}`,
      `alerts: ${evidence.totals.alerts}`,
      `medium or higher: ${evidence.totals.mediumOrHigher}`,
      `unresolved medium or higher: ${evidence.totals.unresolvedMediumOrHigher}`,
      'evidence: nfr-tests/results/zap-security-report.json',
      'evidence: nfr-tests/results/zap-security-report.html',
      '',
    ].join('\n'),
  );
}
// prints a required env var, throws if empty
function required(name) {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is required.`);
  return value;
}

// parse env var as pos int, falls back to default and throws if result not valid pos int
function positiveInteger(name, fallback) {
  const value = Number(process.env[name] || fallback);
  if (!Number.isInteger(value) || value <= 0) {
    throw new Error(`${name} must be a positive integer.`);
  }
  return value;
}

function writeJson(filePath, value) {
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
});
