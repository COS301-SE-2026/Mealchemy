// ------ convert raw ZAP output into safe, enforceable evidence ---------

/* what it does:
    combined public and authenticated reports.
    normalizes values.
    removes query strings and sensitve details
    redacts creds and JWTs.
    classifies medium, high, critical findings.
    matches findings to exact reviewed exceptions.
    fails when a scan fails or a medium/high finding remains unresolved.
    generates JSON and readable HTML.
 */

// ------------------------------

const fs = require('node:fs');

const RISK_LEVELS = {
  informational: 0,
  info: 0,
  low: 1,
  medium: 2,
  high: 3,
  critical: 4,
};

function evaluateReports({
  reports,
  acceptedFindings,
  manifest,
  image,
  scanRuns,
  secrets,
}) {
  const alerts = reports.flatMap(({ scope, report }) =>
    extractAlerts(report).map((alert) => normalizeAlert(scope, alert)),
  );
  const accepted = validateAcceptedFindings(acceptedFindings);

  const findings = alerts.map((alert) => {
    const acceptance = accepted.find(
      (candidate) => candidate.fingerprint === alert.fingerprint,
    );
    return acceptance ? { ...alert, acceptance } : alert;
  });
  const mediumOrHigher = findings.filter((finding) => finding.riskLevel >= 2);
  const unresolved = mediumOrHigher.filter((finding) => !finding.acceptance);
  const runtimePassed = scanRuns.every((run) => run.exitCode === 0);

  const evidence = redactSecrets(
    {
      requirement:
        'Zero unresolved medium, high, or critical ZAP findings on staging',
      executedAt: new Date().toISOString(),
      target: 'staging',
      scanPolicy: {
        operations: 'GET only',
        publicAndAuthenticatedScopes: true,
        productionActivelyScanned: false,
        attackStrength: 'Low',
      },
      zapImage: image,
      manifest,
      scanRuns,
      totals: {
        alerts: findings.length,
        mediumOrHigher: mediumOrHigher.length,
        acceptedMediumOrHigher: mediumOrHigher.length - unresolved.length,
        unresolvedMediumOrHigher: unresolved.length,
      },
      findings,
      passed: runtimePassed && unresolved.length === 0,
    },
    secrets,
  );

  assertNoJwt(evidence, secrets);
  return evidence;
}

function extractAlerts(report) {
  const sites = array(report.site || report.sites);
  return sites.flatMap((site) => array(site.alerts || site.alert));
}

function normalizeAlert(scope, alert) {
  const risk = normalizeRisk(alert.riskdesc || alert.risk || alert.riskcode);
  const urls = array(alert.instances || alert.instance)
    .map((instance) => safeUrl(instance.uri || instance.url))
    .filter(Boolean);
  const primaryUrl = urls[0] || 'unknown-url';
  const pluginId = String(alert.pluginid || alert.pluginId || 'unknown-rule');

  return {
    fingerprint: `${pluginId}|${primaryUrl}`,
    scope,
    pluginId,
    name: text(alert.alert || alert.name),
    risk: risk.name,
    riskLevel: risk.level,
    confidence: text(alert.confidence),
    cweId: text(alert.cweid || alert.cweId),
    urls: [...new Set(urls)],
    description: text(alert.desc || alert.description),
    solution: text(alert.solution),
    reference: text(alert.reference),
  };
}

function validateAcceptedFindings(findings) {
  if (!Array.isArray(findings)) {
    throw new TypeError('accepted-findings.json must contain a JSON array.');
  }

  return findings.map((finding, index) => {
    for (const key of ['fingerprint', 'reason', 'owner', 'reviewBy']) {
      if (typeof finding?.[key] !== 'string' || !finding[key].trim()) {
        throw new TypeError(
          `Accepted finding ${index + 1} requires a non-empty ${key}.`,
        );
      }
    }

    if (Number.isNaN(Date.parse(finding.reviewBy))) {
      throw new TypeError(
        `Accepted finding ${index + 1} has an invalid reviewBy date.`,
      );
    }

    return {
      fingerprint: finding.fingerprint,
      reason: finding.reason,
      owner: finding.owner,
      reviewBy: finding.reviewBy,
      reference: text(finding.reference),
    };
  });
}

function redactSecrets(value, secrets = []) {
  if (Array.isArray(value)) {
    return value.map((item) => redactSecrets(item, secrets));
  }
  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value).map(([key, item]) => [
        key,
        redactSecrets(item, secrets),
      ]),
    );
  }
  if (typeof value !== 'string') {
    return value;
  }

  let result = value;
  for (const secret of secrets.filter(Boolean)) {
    result = result.split(secret).join('[REDACTED]');
  }
  return redactJwtLikeTokens(result);
}
// extra JWT check
function assertNoJwt(value, secrets = []) {
  const serialized = JSON.stringify(value);
  const containsJwt = containsJwtLikeToken(serialized);
  const containsSecret = secrets.filter(Boolean).some((secret) =>
    serialized.includes(secret),
  );

  if (containsJwt || containsSecret) {
    throw new Error('Refusing to write ZAP evidence containing a JWT.');
  }
}

// html report
function renderHtml(evidence) {
  const rows = evidence.findings
    .map(
      (finding) => `
        <tr>
          <td>${escapeHtml(finding.risk)}</td>
          <td>${escapeHtml(finding.name)}</td>
          <td>${escapeHtml(finding.scope)}</td>
          <td>${escapeHtml(finding.urls.join(', '))}</td>
          <td>${finding.acceptance ? 'Accepted with review record' : 'Open'}</td>
        </tr>`,
    )
    .join('');

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mealchemy staging ZAP evidence</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 2rem; color: #202124; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #dadce0; padding: 0.6rem; text-align: left; vertical-align: top; }
    th { background: #f1f3f4; }
    .pass { color: #137333; }
    .fail { color: #b3261e; }
  </style>
</head>
<body>
  <h1>Mealchemy staging ZAP evidence</h1>
  <p>Executed: ${escapeHtml(evidence.executedAt)}</p>
  <p>Status: <strong class="${evidence.passed ? 'pass' : 'fail'}">${evidence.passed ? 'PASS' : 'FAIL'}</strong></p>
  <p>Unresolved medium-or-higher findings: ${evidence.totals.unresolvedMediumOrHigher}</p>
  <p>Scope: staging public GET endpoints and authenticated safe GET endpoints. Production was not actively scanned.</p>
  <table>
    <thead><tr><th>Risk</th><th>Finding</th><th>Scope</th><th>URLs</th><th>Disposition</th></tr></thead>
    <tbody>${rows || '<tr><td colspan="5">No alerts reported.</td></tr>'}</tbody>
  </table>
</body>
</html>\n`;
}

function loadJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

// takes ZAP risk and puts it into consistent {name level} pair
function normalizeRisk(value) {
  const raw = String(value ?? '').trim();
  if (/^\d+$/.test(raw)) {
    const level = Math.max(0, Math.min(4, Number(raw)));
    const name = ['Informational', 'Low', 'Medium', 'High', 'Critical'][level];
    return { name, level };
  }

  const name = raw.split(' ')[0].toLowerCase();
  return {
    name: name ? `${name[0].toUpperCase()}${name.slice(1)}` : 'Informational',
    level: RISK_LEVELS[name] ?? 0,
  };
}

// strips query strings from a url
function safeUrl(value) {
  if (!value) return '';
  try {
    const url = new URL(value);
    return `${url.origin}${url.pathname}`;
  } catch {
    // ZAP can report malformed URLs, still remove any query data from them.
    return String(value).split('?')[0];
  }
}

function redactJwtLikeTokens(value) {
  let output = '';
  let cursor = 0;

  while (cursor < value.length) {
    if (!isJwtCharacter(value[cursor])) {
      output += value[cursor];
      cursor += 1;
      continue;
    }

    let end = cursor;
    while (end < value.length && isJwtCharacter(value[end])) {
      end += 1;
    }
    const candidate = value.slice(cursor, end);
    output += isJwtLikeToken(candidate) ? '[REDACTED]' : candidate;
    cursor = end;
  }

  return output;
}

function containsJwtLikeToken(value) {
  return redactJwtLikeTokens(value) !== value;
}

function isJwtLikeToken(value) {
  const segments = value.split('.');
  return segments.length === 3 && segments.every((segment) => segment.length >= 10);
}

function isJwtCharacter(value) {
  if (value === '.' || value === '-' || value === '_') return true;
  const code = value.charCodeAt(0);
  return (
    (code >= 48 && code <= 57) ||
    (code >= 65 && code <= 90) ||
    (code >= 97 && code <= 122)
  );
}

// coerce val into array, null as empty
// needed beacuse ZAPs xml derived JSON collapses repeated tags to an aray but a single occurrence to a single object or zero alerts the object won't exist.
//makes zap output shape more predicatble.
function array(value) {
  if (!value) return [];
  return Array.isArray(value) ? value : [value];
}

// coerce val into string, null as empty string
function text(value) {
  return value == null ? '' : String(value);
}

function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

module.exports = {
  assertNoJwt,
  evaluateReports,
  loadJson,
  redactSecrets,
  renderHtml,
};
