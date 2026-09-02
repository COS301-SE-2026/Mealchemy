import { fail } from 'k6';
import http from 'k6/http';
import { check } from 'k6';

// -----shared k6 environment and authentication model------
// every k6 test uses this same login behaviour
// only local or staging

export const environment = __ENV.NFR_ENVIRONMENT || '';
export const baseUrl = (__ENV.STAGING_BASE_URL || '').replace(/\/+$/, '');

// allows only local or staging
export function validateEnvironment() {
  if (!['local', 'staging'].includes(environment)) {
    fail('NFR_ENVIRONMENT must be either local or staging.');
  }
  // stops id no backend url is supplied
  if (!baseUrl) {
    fail('STAGING_BASE_URL is required.');
  }
  //require https to prevent creds sent over plain
  if (environment === 'staging' && !baseUrl.startsWith('https://')) {
    fail('Staging NFR tests require an HTTPS base URL.');
  }

  if (
    environment === 'local' &&
    !baseUrl.startsWith('http://localhost') &&
    !baseUrl.startsWith('http://127.0.0.1')
  ) {
    fail('Local NFR tests may only target localhost.');
  }
}

//reads disposable test account;s email and password from enviornment
export function login() {
  const email = __ENV.NFR_TEST_EMAIL;
  const password = __ENV.NFR_TEST_PASSWORD;

  if (!email || !password) {
    fail('NFR_TEST_EMAIL and NFR_TEST_PASSWORD are required.');
  }

  //build /auth/logibn url and onverts to json request body
  const response = http.post(
    `${baseUrl}/auth/login`,
    JSON.stringify({ email, password }),
    {
      headers: { 'Content-Type': 'application/json' },
      tags: { endpoint: 'auth-login', measured: 'false' },
    },
  );

  // stores whether every login check passed
  // checks that the response contains a nonempty string 
  const loginSucceeded = check(response, {
    'test account login succeeds': (result) => result.status === 200,
    'login response contains a token': (result) =>
      typeof result.json('token') === 'string' && result.json('token').length > 0,
  });

  if (!loginSucceeded) {
    fail(`Could not authenticate the NFR test account (HTTP ${response.status}).`);
  }
  // return token for authenticated request
  return response.json('token');
}
