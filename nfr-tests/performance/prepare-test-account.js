
// -- prepares the disposable staging account with representative data ---
/* 
only file that creates or updates application data.
k6 load test logs into this account once during setup.

all 500/ 1000 users virtual users will recieve the same token and perform read-only
gives the disposable account enough realisitc content that performace tests measure populated responses.

script can issue:
    3 vault creations
    30 pantry-item creations
    8 shopping-list creations
    48 shopping-item creations
    20 recipe creations
    60 ingredient creations
    60 step creations
    2 profile/preference updates 
*/

// nodes filesystem API for creating the evidence directory and file
const fs = require('node:fs');
const path = require('node:path');

//default repsentative dataset
const DEFAULT_TARGETS = {
  vaults: 4,
  pantryItems: 30,
  shoppingLists: 8,
  shoppingListItems: 6,
  recipes: 20,
  recipeIngredients: 3,
  recipeSteps: 3,
};

async function main() {
  const config = readConfig();
  const client = await createClient(config);

  if (!config.verifyOnly) {
    await configureProfile(client);
    await configurePreferences(client);
    const referenceData = await loadReferenceData(client);
    const folder = await prepareVaultsAndFolder(client, config.targets);
    await preparePantry(client, referenceData.ingredients, referenceData.unit, config.targets);
    await prepareShoppingLists(
      client,
      referenceData.ingredients,
      referenceData.unit,
      config.targets,
    );
    await prepareRecipes(
      client,
      referenceData,
      folder.folderId,
      config.targets,
    );
  }

  const evidence = await verifyDataset(client, config);
  const serialized = `${JSON.stringify(evidence, null, 2)}\n`;
  process.stdout.write(serialized);

  if (config.evidencePath) {
    fs.mkdirSync(path.dirname(config.evidencePath), { recursive: true });
    fs.writeFileSync(config.evidencePath, serialized);
  }

  if (!evidence.passed) {
    process.exitCode = 1;
  }
}

// config validation
function readConfig() {
  if (process.env.NFR_ENVIRONMENT !== 'staging') {
    throw new Error('Account preparation requires NFR_ENVIRONMENT=staging.');
  }

  const baseUrl = required('STAGING_BASE_URL').replace(/\/+$/, '');
  const target = new URL(baseUrl);
  if (target.protocol !== 'https:') {
    throw new Error('Account preparation requires an HTTPS staging target.');
  }
  if (
    !target.hostname.toLowerCase().includes('staging') &&
    process.env.NFR_CONFIRMED_STAGING_HOST !== target.hostname
  ) {
    throw new Error(
      'The target hostname does not identify staging. Set NFR_CONFIRMED_STAGING_HOST to the exact verified hostname.',
    );
  }
  if (process.env.PRODUCTION_BASE_URL) {
    const productionHost = new URL(process.env.PRODUCTION_BASE_URL).hostname;
    if (productionHost === target.hostname) {
      throw new Error('Refusing to prepare data on the production hostname.');
    }
  }

  const verifyOnly = process.argv.includes('--verify-only');
  if (
    !verifyOnly &&
    process.env.NFR_ACCOUNT_PREP_ACK !== 'staging-disposable-account'
  ) {
    throw new Error(
      'Set NFR_ACCOUNT_PREP_ACK=staging-disposable-account before creating staging test data.',
    );
  }

  return {
    baseUrl,
    email: required('NFR_TEST_EMAIL'),
    password: required('NFR_TEST_PASSWORD'),
    verifyOnly,
    evidencePath: process.env.NFR_EVIDENCE_PATH
      ? path.resolve(process.env.NFR_EVIDENCE_PATH)
      : null,
    targets: {
      vaults: positiveInteger('NFR_TARGET_VAULTS', DEFAULT_TARGETS.vaults),
      pantryItems: positiveInteger(
        'NFR_TARGET_PANTRY_ITEMS',
        DEFAULT_TARGETS.pantryItems,
      ),
      shoppingLists: positiveInteger(
        'NFR_TARGET_SHOPPING_LISTS',
        DEFAULT_TARGETS.shoppingLists,
      ),
      shoppingListItems: positiveInteger(
        'NFR_TARGET_SHOPPING_LIST_ITEMS',
        DEFAULT_TARGETS.shoppingListItems,
      ),
      recipes: positiveInteger('NFR_TARGET_RECIPES', DEFAULT_TARGETS.recipes),
      recipeIngredients: positiveInteger(
        'NFR_TARGET_RECIPE_INGREDIENTS',
        DEFAULT_TARGETS.recipeIngredients,
      ),
      recipeSteps: positiveInteger(
        'NFR_TARGET_RECIPE_STEPS',
        DEFAULT_TARGETS.recipeSteps,
      ),
    },
  };
}

async function createClient(config) {
  const response = await fetch(`${config.baseUrl}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: config.email, password: config.password }),
  });
  const body = await parseResponse(response);
  if (!response.ok || typeof body?.token !== 'string' || !body.token) {
    throw new Error(
      `Could not authenticate the disposable NFR account (HTTP ${response.status}).`,
    );
  }

  return async function request(apiPath, options = {}) {
    const method = options.method || 'GET';
    const apiResponse = await fetch(`${config.baseUrl}${apiPath}`, {
      method,
      headers: {
        Authorization: `Bearer ${body.token}`,
        ...(options.body === undefined
          ? {}
          : { 'Content-Type': 'application/json' }),
      },
      body:
        options.body === undefined ? undefined : JSON.stringify(options.body),
    });
    const responseBody = await parseResponse(apiResponse);
    if (!apiResponse.ok) {
      const message =
        typeof responseBody?.message === 'string'
          ? `: ${responseBody.message}`
          : '';
      throw new Error(
        `${method} ${apiPath} failed with HTTP ${apiResponse.status}${message}`,
      );
    }
    return responseBody;
  };
}

async function configureProfile(request) {
  await request('/user/profile', {
    method: 'PUT',
    body: {
      display_name: 'Mealchemy NFR Test Account',
      avatar_url: '',
      preferred_unit: 'METRIC',
      equipment: [],
    },
  });
}

async function configurePreferences(request) {
  await request('/user/preferences', {
    method: 'PUT',
    body: {
      dietary_restrictions: [],
      allergies: [],
      disliked_ingredients: [],
      flavour_profile: [],
      nutritional_goals: [],
    },
  });
}

async function loadReferenceData(request) {
  const [ingredients, units, cuisineOptions] = await Promise.all([
    request('/api/ingredient-catalogue'),
    request('/api/units-of-measurement'),
    request('/flavourprofileoptions/all'),
  ]);

  if (!Array.isArray(ingredients) || ingredients.length === 0) {
    throw new Error('The staging ingredient catalogue is empty.');
  }
  if (!Array.isArray(units) || units.length === 0) {
    throw new Error('The staging unit catalogue is empty.');
  }
  if (!Array.isArray(cuisineOptions) || cuisineOptions.length === 0) {
    throw new Error('The staging cuisine/flavour profile catalogue is empty.');
  }

  const unit =
    units.find((candidate) => /^(g|gram|grams)$/i.test(candidate.name))?.name ||
    units.find((candidate) => candidate.system === 'METRIC')?.name ||
    units[0].name;
  const cuisineType =
    cuisineOptions.find((candidate) => typeof candidate.value === 'string')
      ?.value || cuisineOptions[0];

  if (typeof unit !== 'string' || typeof cuisineType !== 'string') {
    throw new Error('Could not select valid unit and cuisine values.');
  }

  return { ingredients, unit, cuisineType };
}

async function prepareVaultsAndFolder(request, targets) {
  let vaults = await request('/vaults/owner/vaults');
  for (let index = 1; index < targets.vaults; index += 1) {
    const name = `NFR Shared Vault ${index}`;
    if (!vaults.some((vault) => vault.name === name)) {
      await request('/vaults', {
        method: 'POST',
        body: { vaultType: 'SHARED', name },
      });
      vaults = await request('/vaults/owner/vaults');
    }
  }

  const privateVault = vaults.find(
    (vault) => (vault.vaultType || vault.vault_type) === 'PRIVATE',
  );
  const privateVaultId = id(privateVault, 'vaultId', 'vault_id');
  if (!privateVaultId) {
    throw new Error('The disposable account has no private vault.');
  }

  let folders = await request('/folders/vault/private');
  let folder = folders.find(
    (candidate) =>
      (candidate.folderName || candidate.folder_name) === 'NFR Recipes',
  );
  if (!folder) {
    folder = await request('/folders', {
      method: 'POST',
      body: { vaultId: privateVaultId, folderName: 'NFR Recipes' },
    });
  }

  const folderId = id(folder, 'folderId', 'folder_id');
  if (!folderId) {
    throw new Error('Could not resolve the NFR recipe folder ID.');
  }
  return { folderId };
}

async function preparePantry(request, ingredients, unit, targets) {
  if (ingredients.length < targets.pantryItems) {
    throw new Error(
      `The ingredient catalogue needs at least ${targets.pantryItems} entries to prepare the pantry.`,
    );
  }

  let pantry = await request('/api/pantry');
  const presentIngredientIds = new Set(
    pantry.map((item) => id(item, 'ingId', 'ing_id')).filter(Boolean),
  );

  for (const ingredient of ingredients) {
    if (pantry.length >= targets.pantryItems) break;
    const ingredientId = id(ingredient, 'ingId', 'ing_id');
    if (!ingredientId || presentIngredientIds.has(ingredientId)) continue;

    await request('/api/pantry', {
      method: 'POST',
      body: { ing_id: ingredientId, quantity: 500, unit },
    });
    presentIngredientIds.add(ingredientId);
    pantry.push({ ing_id: ingredientId });
  }
}

async function prepareShoppingLists(request, ingredients, unit, targets) {
  let lists = await request('/api/shopping-lists');

  for (let listIndex = 1; listIndex <= targets.shoppingLists; listIndex += 1) {
    const name = `NFR Shopping List ${listIndex}`;
    let list = lists.find((candidate) => candidate.name === name);
    if (!list) {
      list = await request('/api/shopping-lists', {
        method: 'POST',
        body: { name, status: 'ACTIVE' },
      });
      lists.push(list);
    }

    const listId = id(list, 'shoppingListId', 'shopping_list_id');
    if (!listId) throw new Error(`Could not resolve the ID for ${name}.`);
    const detail = await request(`/api/shopping-lists/${listId}`);
    const existingItems = findItems(detail);

    for (
      let itemIndex = existingItems.length;
      itemIndex < targets.shoppingListItems;
      itemIndex += 1
    ) {
      const ingredient = ingredients[
        (listIndex * targets.shoppingListItems + itemIndex) % ingredients.length
      ];
      await request(`/api/shopping-lists/${listId}/items`, {
        method: 'POST',
        body: {
          ing_id: id(ingredient, 'ingId', 'ing_id'),
          name: ingredient.name,
          quantity: itemIndex + 1,
          unit,
        },
      });
    }
  }
}

async function prepareRecipes(request, referenceData, folderId, targets) {
  let recipes = await request('/recipes/all');

  for (let recipeIndex = 1; recipeIndex <= targets.recipes; recipeIndex += 1) {
    const title = `NFR Recipe ${String(recipeIndex).padStart(2, '0')}`;
    let recipe = recipes.find((candidate) => candidate.title === title);
    if (!recipe) {
      recipe = await request('/recipes/create', {
        method: 'POST',
        body: {
          title,
          description: 'Representative staging recipe for NFR read testing.',
          cuisineType: referenceData.cuisineType,
          prepTimeMins: 15 + recipeIndex,
          cookingTimeMins: 25 + recipeIndex,
          servingSize: 4,
          photoUrl: null,
          videoUrl: null,
          externalUrl: null,
          isCommunityPublished: false,
          folderId,
        },
      });
      recipes.push(recipe);
    }

    const recipeId = id(recipe, 'recipeId', 'recipe_id');
    if (!recipeId) throw new Error(`Could not resolve the ID for ${title}.`);
    await prepareRecipeIngredients(
      request,
      recipeId,
      recipeIndex,
      referenceData,
      targets.recipeIngredients,
    );
    await prepareRecipeSteps(request, recipeId, targets.recipeSteps);
  }
}

async function prepareRecipeIngredients(
  request,
  recipeId,
  recipeIndex,
  referenceData,
  targetCount,
) {
  const existing = await request(`/ingredients/recipe/${recipeId}`);
  const existingIds = new Set(
    existing.map((item) => id(item, 'ingId', 'ing_id')).filter(Boolean),
  );

  for (let offset = 0; offset < targetCount; offset += 1) {
    const ingredient =
      referenceData.ingredients[
        (recipeIndex * targetCount + offset) % referenceData.ingredients.length
      ];
    const ingredientId = id(ingredient, 'ingId', 'ing_id');
    if (existingIds.has(ingredientId)) continue;

    await request(`/ingredients/recipe/${recipeId}/ingredient/create`, {
      method: 'POST',
      body: {
        ingId: ingredientId,
        quantity: 100 + offset * 50,
        unit: referenceData.unit,
        sortOrder: offset + 1,
      },
    });
    existingIds.add(ingredientId);
  }
}

async function prepareRecipeSteps(request, recipeId, targetCount) {
  const existing = await request(`/steps/recipe/${recipeId}`);
  const stepNumbers = new Set(
    existing.map((step) => step.stepNr || step.step_nr).filter(Boolean),
  );

  for (let stepNr = 1; stepNr <= targetCount; stepNr += 1) {
    if (stepNumbers.has(stepNr)) continue;
    await request(`/steps/recipe/${recipeId}/step/create`, {
      method: 'POST',
      body: {
        stepNr,
        content: `NFR preparation step ${stepNr} for recipe ${recipeId}.`,
      },
    });
  }
}

async function verifyDataset(request, config) {
  const [profile, preferences, vaults, pantry, lists, recipes] =
    await Promise.all([
      request('/user/profile'),
      request('/user/preferences'),
      request('/vaults/owner/vaults'),
      request('/api/pantry'),
      request('/api/shopping-lists'),
      request('/recipes/all'),
    ]);
  const nfrLists = lists.filter((list) => list.name?.startsWith('NFR Shopping List'));
  const nfrRecipes = recipes.filter((recipe) => recipe.title?.startsWith('NFR Recipe'));
  const listItemCounts = nfrLists.map((list) =>
    Number(list.numItems ?? list.num_items ?? 0),
  );

  const checks = [
    check('profile is configured', profile.preferred_unit === 'METRIC' || profile.preferredUnit === 'METRIC'),
    check('preferences are readable', preferences && typeof preferences === 'object'),
    check('vault target is met', vaults.length >= config.targets.vaults),
    check('pantry target is met', pantry.length >= config.targets.pantryItems),
    check('shopping-list target is met', nfrLists.length >= config.targets.shoppingLists),
    check(
      'shopping-list item target is met',
      listItemCounts.length >= config.targets.shoppingLists &&
        listItemCounts.every((count) => count >= config.targets.shoppingListItems),
    ),
    check('recipe target is met', nfrRecipes.length >= config.targets.recipes),
  ];

  return {
    requirement: 'Representative staging dataset for performance testing',
    executedAt: new Date().toISOString(),
    mode: config.verifyOnly ? 'verify-only' : 'prepare-and-verify',
    environment: 'staging',
    baseUrl: config.baseUrl,
    targets: config.targets,
    actual: {
      vaults: vaults.length,
      pantryItems: pantry.length,
      nfrShoppingLists: nfrLists.length,
      minimumItemsPerNfrShoppingList:
        listItemCounts.length === 0 ? 0 : Math.min(...listItemCounts),
      nfrRecipes: nfrRecipes.length,
    },
    checks,
    passed: checks.every((currentCheck) => currentCheck.passed),
  };
}

function findItems(detail) {
  for (const key of ['items', 'shoppingListItems', 'shopping_list_items']) {
    if (Array.isArray(detail?.[key])) return detail[key];
  }
  return [];
}

function id(value, ...keys) {
  for (const key of keys) {
    if (Number.isInteger(value?.[key])) return value[key];
  }
  return null;
}

function check(name, passed) {
  return { name, passed: Boolean(passed) };
}

async function parseResponse(response) {
  const text = await response.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch (_) {
    return text;
  }
}

function positiveInteger(name, fallback) {
  const value = Number(process.env[name] || fallback);
  if (!Number.isInteger(value) || value <= 0) {
    throw new Error(`${name} must be a positive integer.`);
  }
  return value;
}

function required(name) {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is required.`);
  return value;
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
});
