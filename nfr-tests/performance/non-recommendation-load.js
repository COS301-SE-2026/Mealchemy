import { check, sleep } from 'k6';
import execution from 'k6/execution';
import http from 'k6/http';
import { Rate, Trend } from 'k6/metrics';
import { createSafeSummary } from '../config/safe-summary.js';

// ------------- main read only k6 LOAD TEST -------------
// test the primary backend reads that support the app's normal and offline-cache synchronizatio workflows

// logs in once during k6 setup, starts configured number of virtual users, rotates through 4 authenticated endpoints.
// checks each response is HTTP 200, marks measured requests separately from login/setup traffic
// Measures p95 latency, failure rate, request rate, throughput.
// Performance mode enforces p95 below 2s and errors below 1%
// Resilience mode enforces successful responses while reporting degraded latency.
// ----------------------------------------------------------

//imports vaildated url, environment name, login function, environment validator
import {
  baseUrl,
  environment,
  login,
  validateEnvironment,
} from '../config/environment.js';

// validates as postive int and defaults to 10 users
// reads duration and defaults to 30s - k6 validates the duration format
// reads delay between each user's request and defaults to 1s
const virtualUsers = positiveInteger('NFR_VUS', 10);
const duration = __ENV.NFR_DURATION || '30s';
const pacingSeconds = positiveNumber('NFR_PACING_SECONDS', 1);
const testProfile = __ENV.NFR_TEST_PROFILE || 'performance';

if (testProfile !== 'performance' && testProfile !== 'resilience') {
  throw new Error('NFR_TEST_PROFILE must be performance or resilience.');
}

const readEndpoints = [
  { name: 'vaults', path: '/vaults/owner/vaults' },
  { name: 'pantry', path: '/api/pantry' },
  { name: 'shopping-lists', path: '/api/shopping-lists' },
  { name: 'recipes', path: '/recipes/all' },
];

const endpointMetrics = {
  vaults: {
    duration: new Trend('endpoint_vaults_duration', true),
    failures: new Rate('endpoint_vaults_failed'),
  },
  pantry: {
    duration: new Trend('endpoint_pantry_duration', true),
    failures: new Rate('endpoint_pantry_failed'),
  },
  'shopping-lists': {
    duration: new Trend('endpoint_shopping_lists_duration', true),
    failures: new Rate('endpoint_shopping_lists_failed'),
  },
  recipes: {
    duration: new Trend('endpoint_recipes_duration', true),
    failures: new Rate('endpoint_recipes_failed'),
  },
};

export const options = {
  scenarios: {
    read_only_load: {
      executor: 'constant-vus',
      vus: virtualUsers,
      duration,
      gracefulStop: '30s',
    },
  },

  thresholds: buildThresholds(testProfile),
};

// runs once before virtual users start
export function setup() {
  validateEnvironment();
  const token = login();

  console.log(
    `Starting ${environment} ${testProfile} read load with ` +
      `${virtualUsers} VUs for ${duration}.`,
  );

  return { token };
}

// uses global iteration number modulo 4 to rotate preictably through 4 endpoints
// GET /vaults/owner/vaults [owned vaults]
// GET/ api/pantry [pantry]
// GET/ api/shopping-lists [shopping list]
// GET/ recipes/all [recipes]
export default function runReadLoad(data) {
  const endpoint =
    readEndpoints[execution.scenario.iterationInTest % readEndpoints.length];
  const response = http.get(`${baseUrl}${endpoint.path}`, {
    headers: { Authorization: `Bearer ${data.token}` },
    tags: { endpoint: endpoint.name, measured: 'true' },
  });

  const metrics = endpointMetrics[endpoint.name];
  metrics.duration.add(response.timings.duration);
  metrics.failures.add(response.status !== 200);

  check(response, {
    [`${endpoint.name} returns HTTP 200`]: (result) => result.status === 200,
  });

  sleep(pacingSeconds);
}

export function handleSummary(data) {
  return createSafeSummary(data, {
    environment,
    testProfile,
    virtualUsers,
    duration,
    pacingSeconds,
  });
}

function buildThresholds(profile) {
  const thresholds = {
    checks: ['rate>0.99'],
    'http_req_failed{measured:true}': [
      {
        threshold: 'rate<0.01',
        abortOnFail: true,
        delayAbortEval: '30s',
      },
    ],
  };

  if (profile === 'performance') {
    thresholds['http_req_duration{measured:true}'] = ['p(95)<2000'];
  }

  return thresholds;
}

// helper for positive whole-number settings
function positiveInteger(name, fallback) {
  const value = Number(__ENV[name] || fallback);
  if (!Number.isInteger(value) || value <= 0) {
    throw new Error(`${name} must be a positive integer.`);
  }
  return value;
}
// helper that permits postive decimal values
function positiveNumber(name, fallback) {
  const value = Number(__ENV[name] || fallback);
  if (!Number.isFinite(value) || value <= 0) {
    throw new Error(`${name} must be a positive number.`);
  }
  return value;
}
