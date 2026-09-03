
// ----- ZAP Security testing ------
// transforms the staging OpenApi definition into safe scan definitions
// ie. creates safe API definitions for ZAP
// Ensures that the complete API isn't imported into an active scanner as Zap could then create, modify, or delete staging data. Ensures read operations before Zap gets API definitions

// Takes complete staging Open-API doc and produced
// - a public GET- only def for health and API documentation
// - and authenticated GET-only def for protected read endpoints

// removed mutation methods such as POST, PUT, PATCH, DELETE

//-------------------------------------


const PUBLIC_GET_PATHS = new Set([
  '/actuator/health',
  '/v3/api-docs',
  '/swagger-ui/index.html',
]);

const HTTP_METHODS = new Set([
  'get',
  'post',
  'put',
  'patch',
  'delete',
  'head',
  'options',
  'trace',
]);

function prepareOpenApi(document, baseUrl) {
  validateDocument(document);

  const publicDocument = filterGetOperations(
    document,
    baseUrl,
    (apiPath) => PUBLIC_GET_PATHS.has(apiPath),
  );
  addPublicInfrastructurePaths(publicDocument);

  const authenticatedDocument = filterGetOperations(
    document,
    baseUrl,
    (apiPath) => !PUBLIC_GET_PATHS.has(apiPath),
  );

  assertGetOnly(publicDocument, 'public');
  assertGetOnly(authenticatedDocument, 'authenticated');

  const publicPathCount = Object.keys(publicDocument.paths).length;
  const authenticatedPathCount = Object.keys(
    authenticatedDocument.paths,
  ).length;

  if (publicPathCount === 0) {
    throw new Error('The public ZAP definition contains no GET paths.');
  }
  if (authenticatedPathCount === 0) {
    throw new Error('The authenticated ZAP definition contains no GET paths.');
  }

  return {
    publicDocument,
    authenticatedDocument,
    manifest: {
      sourcePathCount: Object.keys(document.paths).length,
      publicGetPathCount: publicPathCount,
      authenticatedGetPathCount: authenticatedPathCount,
      excludedMethods: ['POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS'],
    },
  };
}

function filterGetOperations(document, baseUrl, includePath) {
  const paths = {};

  for (const [apiPath, pathItem] of Object.entries(document.paths)) {
    if (!pathItem?.get || !includePath(apiPath, pathItem.get)) {
      continue;
    }

    paths[apiPath] = {
      ...copyPathMetadata(pathItem),
      get: clone(pathItem.get),
    };
  }

  return {
    openapi: document.openapi,
    info: clone(document.info),
    servers: [{ url: baseUrl }],
    tags: clone(document.tags || []),
    paths,
    components: clone(document.components || {}),
  };
}

function copyPathMetadata(pathItem) {
  const metadata = {};

  for (const [key, value] of Object.entries(pathItem)) {
    if (!HTTP_METHODS.has(key.toLowerCase())) {
      metadata[key] = clone(value);
    }
  }

  return metadata;
}

function addPublicInfrastructurePaths(document) {
  for (const apiPath of PUBLIC_GET_PATHS) {
    if (document.paths[apiPath]) {
      document.paths[apiPath].get.security = [];
      continue;
    }

    document.paths[apiPath] = {
      get: {
        summary: `Public staging check for ${apiPath}`,
        security: [],
        responses: {
          200: { description: 'Public endpoint is available.' },
        },
      },
    };
  }
}

function assertGetOnly(document, label) {
  for (const [apiPath, pathItem] of Object.entries(document.paths)) {
    for (const key of Object.keys(pathItem)) {
      const normalized = key.toLowerCase();
      if (HTTP_METHODS.has(normalized) && normalized !== 'get') {
        throw new Error(
          `${label} ZAP definition contains forbidden ${normalized.toUpperCase()} operation at ${apiPath}.`,
        );
      }
    }
  }
}

function validateDocument(document) {
  if (!document || typeof document !== 'object') {
    throw new Error('The staging OpenAPI response is not a JSON object.');
  }
  if (typeof document.openapi !== 'string') {
    throw new Error('The staging API must expose an OpenAPI 3 document.');
  }
  if (!document.paths || typeof document.paths !== 'object') {
    throw new Error('The staging OpenAPI document has no paths object.');
  }
}

function clone(value) {
  return value === undefined ? undefined : structuredClone(value);
}

module.exports = {
  PUBLIC_GET_PATHS,
  assertGetOnly,
  prepareOpenApi,
};
