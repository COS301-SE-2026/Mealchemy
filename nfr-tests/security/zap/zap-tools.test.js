// ----- tests pipelines's safety logic ------


const test = require('node:test');
const assert = require('node:assert/strict');

const { assertGetOnly, prepareOpenApi } = require('./prepare-openapi');
const {
  assertNoJwt,
  evaluateReports,
  redactSecrets,
} = require('./evaluate-zap-report');

const baseUrl = 'https://mealchemy-backend-staging.example.test';

test('prepares separate public and authenticated GET-only definitions', () => {
  const source = {
    openapi: '3.0.1',
    info: { title: 'Test API', version: '1' },
    paths: {
      '/recipes/all': {
        get: { responses: { 200: { description: 'ok' } } },
        post: { responses: { 201: { description: 'created' } } },
      },
      '/actuator/health': {
        get: { responses: { 200: { description: 'ok' } } },
        delete: { responses: { 204: { description: 'deleted' } } },
      },
    },
    components: {},
  };

  const prepared = prepareOpenApi(source, baseUrl);

  assert.deepEqual(Object.keys(prepared.authenticatedDocument.paths), [
    '/recipes/all',
  ]);
  assert.deepEqual(
    Object.keys(prepared.publicDocument.paths).sort(),
    ['/actuator/health', '/swagger-ui/index.html', '/v3/api-docs'].sort(),
  );
  assertGetOnly(prepared.publicDocument, 'public');
  assertGetOnly(prepared.authenticatedDocument, 'authenticated');
  assert.equal(prepared.manifest.authenticatedGetPathCount, 1);
  assert.equal(prepared.manifest.publicGetPathCount, 3);
});

test('fails evidence when a medium finding is unresolved', () => {
  const evidence = evaluateReports({
    reports: [{ scope: 'authenticated', report: reportWithMediumAlert() }],
    acceptedFindings: [],
    manifest: {},
    image: 'zap:test',
    scanRuns: [{ scope: 'authenticated', exitCode: 0 }],
    secrets: [],
  });

  assert.equal(evidence.totals.mediumOrHigher, 1);
  assert.equal(evidence.totals.unresolvedMediumOrHigher, 1);
  assert.equal(evidence.passed, false);
});

test('accepts only an explicitly documented finding fingerprint', () => {
  const evidence = evaluateReports({
    reports: [{ scope: 'authenticated', report: reportWithMediumAlert() }],
    acceptedFindings: [
      {
        fingerprint: '10001|https://staging.example.test/recipes/all',
        reason: 'Reviewed false positive in the disposable staging response.',
        owner: 'Security reviewer',
        reviewBy: '2099-12-31',
        reference: 'NFR review record',
      },
    ],
    manifest: {},
    image: 'zap:test',
    scanRuns: [{ scope: 'authenticated', exitCode: 0 }],
    secrets: [],
  });

  assert.equal(evidence.totals.unresolvedMediumOrHigher, 0);
  assert.equal(evidence.totals.acceptedMediumOrHigher, 1);
  assert.equal(evidence.passed, true);
});

test('redacts JWTs and supplied credentials from evidence strings', () => {
  const jwt =
    'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0ZXN0LXVzZXIifQ.signaturevalue';
  const redacted = redactSecrets(
    `Authorization: Bearer ${jwt}; email=test@example.test`,
    [jwt, 'test@example.test'],
  );

  assert.equal(redacted.includes(jwt), false);
  assert.equal(redacted.includes('test@example.test'), false);
  assert.doesNotThrow(() => assertNoJwt(redacted, [jwt]));
});

function reportWithMediumAlert() {
  return {
    site: [
      {
        alerts: [
          {
            pluginid: '10001',
            alert: 'Example finding',
            riskdesc: 'Medium (High)',
            confidence: 'High',
            instances: [
              {
                uri: 'https://staging.example.test/recipes/all?sample=value',
              },
            ],
            desc: 'Example description',
            solution: 'Example solution',
          },
        ],
      },
    ],
  };
}
