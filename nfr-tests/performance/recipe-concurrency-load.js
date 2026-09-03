// --------- tests recipes operations only ----------

import { check, fail, sleep } from 'k6';
import http from 'k6/http';
import { Rate, Trend } from 'k6/metrics';
import { createSafeSummary } from '../config/safe-summary.js';
import {
  baseUrl,
  environment,
  login,
  validateEnvironment,
} from '../config/environment.js';

const virtualUsers = positiveInteger('NFR_VUS', 10);
const duration = __ENV.NFR_DURATION || '5m';
const pacingSeconds = positiveNumber('NFR_PACING_SECONDS', 30);
const startupStaggerSeconds = nonNegativeNumber(
  'NFR_STARTUP_STAGGER_SECONDS',
  60,
);

const mutationAcknowledgement = 'store-and-delete-test-recipes';
const fullScaleAcknowledgement = 'staging-1000-recipe-users';

if (virtualUsers > 1000) {
  throw new Error('NFR_VUS may not exceed the 1,000-user SRS target.');
}

if (__ENV.NFR_RECIPE_MUTATION_ACK !== mutationAcknowledgement) {
  throw new Error(
    `Set NFR_RECIPE_MUTATION_ACK=${mutationAcknowledgement} to acknowledge ` +
      'temporary recipe creation and cleanup.',
  );
}

if (
  environment === 'staging' &&
  virtualUsers === 1000 &&
  __ENV.NFR_1000_USER_ACK !== fullScaleAcknowledgement
) {
  throw new Error(
    `Set NFR_1000_USER_ACK=${fullScaleAcknowledgement} to acknowledge the ` +
      'full 1,000-user staging test.',
  );
}

const storeDuration = new Trend('endpoint_recipe_store_duration', true);
const storeFailures = new Rate('endpoint_recipe_store_failed');
const retrieveDuration = new Trend('endpoint_recipe_retrieve_duration', true);
const retrieveFailures = new Rate('endpoint_recipe_retrieve_failed');

export const options = {
  scenarios: {
    recipe_concurrency: {
      executor: 'constant-vus',
      vus: virtualUsers,
      duration,
      gracefulStop: '30s',
    },
  },
  setupTimeout: '1m',
  teardownTimeout: '10m',
  thresholds: {
    checks: ['rate>0.99'],
    'http_req_failed{measured:true}': ['rate<0.01'],
    'http_req_duration{measured:true}': ['p(95)<5000'],
    endpoint_recipe_store_failed: ['rate<0.01'],
    endpoint_recipe_retrieve_failed: ['rate<0.01'],
    endpoint_recipe_store_duration: ['p(95)<5000'],
    endpoint_recipe_retrieve_duration: ['p(95)<2000'],
  },
};

let creationAttempted = false;
let createdRecipeId;

export function setup() {
  validateEnvironment();
  const token = login();
  const referenceResponse = http.get(`${baseUrl}/recipes/all`, {
    headers: authorizationHeaders(token),
    tags: { endpoint: 'recipe-reference', measured: 'false' },
  });
  const folderResponse = http.get(`${baseUrl}/folders/vault/private`, {
    headers: authorizationHeaders(token),
    tags: { endpoint: 'recipe-folder-reference', measured: 'false' },
  });
  const recipes = parseJson(referenceResponse);
  const folders = parseJson(folderResponse);
  const referenceRecipe = Array.isArray(recipes)
    ? recipes.find(
        (recipe) =>
          typeof recipe?.cuisineType === 'string' && recipe.cuisineType.length > 0,
      )
    : null;
  const recipeFolder = Array.isArray(folders)
    ? folders.find(
        (folder) =>
          (folder?.folderName || folder?.folder_name) === 'NFR Recipes',
      )
    : null;
  const folderId = recipeFolder?.folderId || recipeFolder?.folder_id;

  if (referenceResponse.status !== 200 || !referenceRecipe) {
    fail(
      'The disposable account needs at least one prepared recipe with a cuisine type.',
    );
  }
  if (folderResponse.status !== 200 || !Number.isInteger(folderId)) {
    fail(
      'The disposable account needs the prepared private NFR Recipes folder.',
    );
  }

  const runPrefix = `NFR 1000 ${new Date().toISOString()} `;
  console.log(
    `Starting ${environment} recipe storage and retrieval test with ` +
      `${virtualUsers} concurrent VUs for ${duration}.`,
  );

  return {
    token,
    runPrefix,
    cuisineType: referenceRecipe.cuisineType,
    folderId,
  };
}

export default function runRecipeConcurrency(data) {
  if (!creationAttempted) {
    creationAttempted = true;
    sleep(((__VU - 1) / virtualUsers) * startupStaggerSeconds);
    createdRecipeId = storeRecipe(data);
  }

  if (createdRecipeId !== undefined) {
    retrieveRecipe(data.token, createdRecipeId);
  }

  sleep(pacingSeconds);
}

export function teardown(data) {
  const response = http.get(`${baseUrl}/recipes/all`, {
    headers: authorizationHeaders(data.token),
    tags: { endpoint: 'recipe-cleanup-list', measured: 'false' },
  });
  const recipes = parseJson(response);

  if (response.status !== 200 || !Array.isArray(recipes)) {
    console.error('Recipe cleanup could not list the run records.');
    return;
  }

  const recipeIds = recipes
    .filter(
      (recipe) =>
        typeof recipe?.title === 'string' &&
        recipe.title.startsWith(data.runPrefix) &&
        Number.isInteger(recipe.recipeId),
    )
    .map((recipe) => recipe.recipeId);

  let cleanupFailures = 0;
  for (let index = 0; index < recipeIds.length; index += 20) {
    const responses = http.batch(
      recipeIds.slice(index, index + 20).map((recipeId) => ({
        method: 'DELETE',
        url: `${baseUrl}/recipes/delete/${recipeId}`,
        params: {
          headers: authorizationHeaders(data.token),
          tags: { endpoint: 'recipe-cleanup-delete', measured: 'false' },
        },
      })),
    );
    cleanupFailures += responses.filter(
      (cleanupResponse) =>
        cleanupResponse.status !== 200 && cleanupResponse.status !== 204,
    ).length;
  }

  console.log(
    `Recipe cleanup removed ${recipeIds.length - cleanupFailures} temporary ` +
      `records; failures: ${cleanupFailures}.`,
  );
}

export function handleSummary(data) {
  return createSafeSummary(data, {
    requirement:
      'Store and retrieve saved recipe data for up to 1,000 concurrent users',
    environment,
    testProfile: 'recipe-concurrency',
    virtualUsers,
    duration,
    pacingSeconds,
    startupStaggerSeconds,
    operationModel:
      'Each VU stores one temporary private recipe and repeatedly retrieves it',
  });
}

function storeRecipe(data) {
  const response = http.post(
    `${baseUrl}/recipes/create`,
    JSON.stringify({
      title: `${data.runPrefix}VU ${__VU}`,
      description: 'Temporary recipe created by the NFR concurrency test.',
      cuisineType: data.cuisineType,
      prepTimeMins: 10,
      cookingTimeMins: 20,
      servingSize: 4,
      photoUrl: null,
      videoUrl: null,
      externalUrl: null,
      isCommunityPublished: false,
      folderId: data.folderId,
    }),
    {
      headers: {
        ...authorizationHeaders(data.token),
        'Content-Type': 'application/json',
      },
      tags: { endpoint: 'recipe-store', measured: 'true' },
    },
  );
  const body = parseJson(response);
  const recipeId = body?.recipeId;
  const succeeded =
    (response.status === 200 || response.status === 201) &&
    Number.isInteger(recipeId);

  storeDuration.add(response.timings.duration);
  storeFailures.add(!succeeded);
  check(response, {
    'recipe storage succeeds and returns an ID': () => succeeded,
  });

  return succeeded ? recipeId : undefined;
}

function retrieveRecipe(token, recipeId) {
  const response = http.get(`${baseUrl}/recipes/single/${recipeId}`, {
    headers: authorizationHeaders(token),
    tags: { endpoint: 'recipe-retrieve', measured: 'true' },
  });
  const body = parseJson(response);
  const succeeded = response.status === 200 && body?.recipeId === recipeId;

  retrieveDuration.add(response.timings.duration);
  retrieveFailures.add(!succeeded);
  check(response, {
    'saved recipe retrieval returns the matching recipe': () => succeeded,
  });
}

function authorizationHeaders(token) {
  return { Authorization: `Bearer ${token}` };
}

function parseJson(response) {
  try {
    return response.json();
  } catch (error) {
    return null;
  }
}

function positiveInteger(name, fallback) {
  const value = Number(__ENV[name] || fallback);
  if (!Number.isInteger(value) || value <= 0) {
    throw new Error(`${name} must be a positive integer.`);
  }
  return value;
}

function positiveNumber(name, fallback) {
  const value = Number(__ENV[name] || fallback);
  if (!Number.isFinite(value) || value <= 0) {
    throw new Error(`${name} must be a positive number.`);
  }
  return value;
}

function nonNegativeNumber(name, fallback) {
  const value = Number(__ENV[name] || fallback);
  if (!Number.isFinite(value) || value < 0) {
    throw new Error(`${name} must be a non-negative number.`);
  }
  return value;
}
