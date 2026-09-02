// -------- k6 Authorization test ---------
//proves that the backend's auth and route proetction tactic works across the API

/* what it does:
  enumerates the protected backend routes.
  calls each route without a token.
  calls each route with an invalid token.
  uses nonexistent IDs and empty bodies so mutation endpoints cannot alter data.
  uses a real disposable account token for 4 get control requests.
  requires those valid token rquests to return http 200.
  counts any unexpected authroization result.
  fails unless auth failures remains 0.
*/ 


import { check } from 'k6';
import http from 'k6/http';
import { Counter } from 'k6/metrics';
import { createSafeSummary } from '../config/safe-summary.js';

import {
  baseUrl,
  login,
  validateEnvironment,
} from '../config/environment.js';

const nonexistentId = 2147483647;
const authorizationFailures = new Counter('authorization_failures');

const protectedRoutes = [
  route('vault members', 'GET', `/vault/${nonexistentId}/members/all`),
  route('create vault member', 'POST', `/vault/${nonexistentId}/members/create`),
  route('delete vault member', 'DELETE', `/vault/${nonexistentId}/members/delete`),
  route('dietary restrictions', 'GET', '/dietaryrestrictions/all'),
  route('user profile', 'GET', '/user/profile'),
  route('update user profile', 'PUT', '/user/profile'),
  route('logout', 'POST', '/auth/logout'),
  route('owned vaults', 'GET', '/vaults/owner/vaults'),
  route('vault by id', 'GET', `/vaults/${nonexistentId}`),
  route('accessible vaults', 'GET', '/vaults/accessible'),
  route('create vault', 'POST', '/vaults'),
  route('update vault', 'PUT', `/vaults/${nonexistentId}`),
  route('delete vault', 'DELETE', `/vaults/${nonexistentId}`),
  route('folder recipes', 'GET', `/recipefolders/recipes/${nonexistentId}`),
  route('recipe folders', 'GET', `/recipefolders/folders/${nonexistentId}`),
  route('recipe folder link', 'GET', `/recipefolders/${nonexistentId}`),
  route('create recipe folder link', 'POST', `/recipefolders/folder/${nonexistentId}`),
  route('update recipe folder link', 'PUT', `/recipefolders/${nonexistentId}`),
  route('delete recipe folder link', 'DELETE', `/recipefolders/${nonexistentId}`),
  route('user preferences', 'GET', '/user/preferences'),
  route('update user preferences', 'PUT', '/user/preferences'),
  route('private vault folders', 'GET', '/folders/vault/private'),
  route('vault folders', 'GET', `/folders/vault/${nonexistentId}`),
  route('folder by name', 'GET', `/folders/${nonexistentId}/folder/name/nfr-nonexistent`),
  route('folder by id', 'GET', `/folders/${nonexistentId}/folder/${nonexistentId}`),
  route('create folder', 'POST', '/folders'),
  route('update folder', 'PUT', `/folders/${nonexistentId}`),
  route('delete folder', 'DELETE', `/folders/vault/${nonexistentId}/folder/${nonexistentId}`),
  route('ingredient categories', 'GET', '/api/categories'),
  route('allergy options', 'GET', '/allergies/all'),
  route('ingredient catalogue', 'GET', '/api/ingredient-catalogue'),
  route('ingredient catalogue search', 'GET', '/api/ingredient-catalogue/search'),
  route('add external ingredient', 'POST', '/api/ingredient-catalogue/add-external'),
  route('shopping lists', 'GET', '/api/shopping-lists'),
  route('create shopping list', 'POST', '/api/shopping-lists'),
  route('update shopping list', 'PUT', `/api/shopping-lists/${nonexistentId}`),
  route('delete shopping list', 'DELETE', `/api/shopping-lists/${nonexistentId}`),
  route('shopping list from recipe', 'POST', `/api/shopping-lists/from-recipe/${nonexistentId}`),
  route(
    'add recipe to shopping list',
    'POST',
    `/api/shopping-lists/add-from-recipe/${nonexistentId}/${nonexistentId}`,
  ),
  route('shopping list by id', 'GET', `/api/shopping-lists/${nonexistentId}`),
  route('create shopping item', 'POST', `/api/shopping-lists/${nonexistentId}/items`),
  route(
    'update shopping item',
    'PUT',
    `/api/shopping-lists/${nonexistentId}/items/${nonexistentId}`,
  ),
  route(
    'toggle purchased item',
    'PATCH',
    `/api/shopping-lists/${nonexistentId}/items/${nonexistentId}/purchased`,
  ),
  route(
    'delete shopping item',
    'DELETE',
    `/api/shopping-lists/${nonexistentId}/items/${nonexistentId}`,
  ),
  route(
    'batch delete shopping items',
    'POST',
    `/api/shopping-lists/${nonexistentId}/items/batch-delete`,
  ),
  route(
    'select all shopping items',
    'PUT',
    `/api/shopping-lists/${nonexistentId}/items/select-all`,
  ),
  route(
    'deselect all shopping items',
    'PUT',
    `/api/shopping-lists/${nonexistentId}/items/deselect-all`,
  ),
  route(
    'complete shopping list',
    'PUT',
    `/api/shopping-lists/${nonexistentId}/complete-shop`,
  ),
  route('units of measurement', 'GET', '/api/units-of-measurement'),
  route('nutritional goals', 'GET', '/nutritionalgoals/all'),
  route('recipe ingredients', 'GET', `/ingredients/recipe/${nonexistentId}`),
  route(
    'create recipe ingredient',
    'POST',
    `/ingredients/recipe/${nonexistentId}/ingredient/create`,
  ),
  route(
    'update recipe ingredient',
    'PUT',
    `/ingredients/recipe/${nonexistentId}/ingredient/${nonexistentId}/edit`,
  ),
  route(
    'delete recipe ingredient',
    'DELETE',
    `/ingredients/recipe/${nonexistentId}/ingredient/${nonexistentId}/delete`,
  ),
  route('pantry', 'GET', '/api/pantry'),
  route('create pantry item', 'POST', '/api/pantry'),
  route('update pantry item', 'PUT', `/api/pantry/${nonexistentId}`),
  route('delete pantry item', 'DELETE', `/api/pantry/${nonexistentId}`),
  route('pantry search', 'GET', '/api/pantry/search'),
  route('recipes', 'GET', '/recipes/all'),
  route('community recipes', 'GET', '/recipes/community'),
  route('recipe by id', 'GET', `/recipes/single/${nonexistentId}`),
  route('create recipe', 'POST', '/recipes/create'),
  route('copy recipe', 'POST', `/recipes/${nonexistentId}/copy`),
  route('recipe photo upload URL', 'POST', `/recipes/${nonexistentId}/photo-upload-url`),
  route('update recipe', 'PUT', `/recipes/edit/${nonexistentId}`),
  route('delete recipe', 'DELETE', `/recipes/delete/${nonexistentId}`),
  route('recipe steps', 'GET', `/steps/recipe/${nonexistentId}`),
  route('create recipe step', 'POST', `/steps/recipe/${nonexistentId}/step/create`),
  route(
    'update recipe step',
    'PUT',
    `/steps/recipe/${nonexistentId}/step/${nonexistentId}/edit`,
  ),
  route('reorder recipe steps', 'PUT', `/steps/recipe/${nonexistentId}/reorder`),
  route(
    'delete recipe step',
    'DELETE',
    `/steps/recipe/${nonexistentId}/step/${nonexistentId}/delete`,
  ),
  route('flavour profile options', 'GET', '/flavourprofileoptions/all'),
  route('equipment', 'GET', '/api/equipment'),
];

const validTokenControls = [
  route('owned vaults', 'GET', '/vaults/owner/vaults'),
  route('pantry', 'GET', '/api/pantry'),
  route('shopping lists', 'GET', '/api/shopping-lists'),
  route('recipes', 'GET', '/recipes/all'),
];

export const options = {
  scenarios: {
    authorization_matrix: {
      executor: 'shared-iterations',
      vus: 1,
      iterations: 1,
      maxDuration: '2m',
    },
  },
  thresholds: {
    authorization_failures: ['count==0'],
    checks: ['rate==1'],
  },
};

export function setup() {
  validateEnvironment();
  return { token: login() };
}

export default function runAuthorizationMatrix(data) {
  authorizationFailures.add(0, { initialization: 'true' });

  for (const protectedRoute of protectedRoutes) {
    verifyRejected(protectedRoute, null, 'missing-token');
    verifyRejected(protectedRoute, 'not-a-valid-jwt', 'invalid-token');
  }

  for (const control of validTokenControls) {
    const response = send(control, data.token, 'valid-token');
    check(response, {
      [`valid token: ${control.name} returns HTTP 200`]:
        (result) => result.status === 200,
    });
  }
}

export function handleSummary(data) {
  return createSafeSummary(data);
}

function verifyRejected(protectedRoute, token, credentialCase) {
  const response = send(protectedRoute, token, credentialCase);
  const rejected = response.status === 401 || response.status === 403;

  if (!rejected) {
    authorizationFailures.add(1, {
      endpoint: protectedRoute.name,
      credential_case: credentialCase,
      observed_status: String(response.status),
    });
  }

  check(response, {
    [`${credentialCase}: ${protectedRoute.name} is rejected`]: () => rejected,
  });
}

function send(targetRoute, token, credentialCase) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  return http.request(
    targetRoute.method,
    `${baseUrl}${targetRoute.path}`,
    targetRoute.body,
    {
      headers,
      tags: {
        endpoint: targetRoute.name,
        credential_case: credentialCase,
        measured: 'false',
      },
      responseCallback:
        credentialCase === 'valid-token'
          ? http.expectedStatuses(200)
          : http.expectedStatuses(401, 403),
    },
  );
}

function route(name, method, path) {
  return {
    name,
    method,
    path,
    body: method === 'GET' ? null : '{}',
  };
}
