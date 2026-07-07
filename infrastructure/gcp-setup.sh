
#----notes -------------------------------------------------------------------
# This is the script that from a fresh clone of repo, deployment can be replicated
#----api explanation----
# run.googleapis.com - cloud run serverless containers. Hosts both backend and engine containers
# artifactregistry.googleapis.com - docker image storage. Images from Ci go here before Cloud Run can deploy it
# secretmanager.googleapis.com - the secret manager. Stores Db credetials and jwt secrte.
# iam.googleapis.com - identity access management. Needed to create service accouns and grant/check roles
# iamcredentials.googleapis.com - short lived credential creation. what WIF uses for a temp token instead of permanent key.
# cloudresourcemanager.googleapis.com - project level resource management. Lets the script run IAM bindings at the project level
# ----------------------------------------------------------------------------
#----addtioional security ----
  # - credentital are never hardcoded, echo statements at end of script with placeholders.
  # - follows least privilege rules.
  #     - two separate service accounts. CD_SA and RUNTIME_SA. This separates the idenentiy that changes the system from the identity that operates the system. This limits permissions with malicious attacks.

  # -Per-secret Iam bindings. this isnt project wide which means each service account can only read the specific secrets it jobs required
  #     - Workload identity federation' two layer filtering.
  #         provider-level --attribute-condition - happens when GCP receives any token claiming to be from gihub actions, checks repo org.
  #     - service-account-level binding. Checks if token's repository matches exact repo
# ----------------------------------------------------------------------------
#----additional notes----
  # - GitHub proves its identity on every single run via a signed OIDC token.
  # -Gcp verifies that signature against hithub's published keys, checks repo, org conditions and then issues a short lived token. Menas no static credentials to leak or rotate.  
  # added service account for engine so that db credentials are limited to backend service
    
# ----------------------------------------------------------------------------
 #----overall process----
#  -enable apis
#  -create artifcat reigstry repo with cleanup policy
#  -create two service accounts
#  -grant iam roles
#  -set up WIF
#  -create empty secret containers
#  -bind per secret access
# - print command instructions to populate secret values    
# ----------------------------------------------------------------------------
# Neon setup,done before running. 
#   Neon org, project, and staging branch are already created.
#   For each branch (production + staging), get the connection string from the
#   Connection pooling OFF gives the non-pooled string (used by Flyway).
#   Connection pooling ON gives the pooled string (used by the Spring Boot app).
#   Credentials are stored as separate secrets.

#---------------------------------------------------------------------------------------------


#safty net, fail if any stage fails, undefined varible is an error
set -euo pipefail

#gcp project identifier and access
PROJECT_ID="mealchemy"
PROJECT_NUMBER="309582551982"
REGION="europe-west3"
GITHUB_ORG="cos301-se-2026"
GITHUB_REPO="Mealchemy"

#name of artifact registery
AR_REPO="mealchemy"

#workload idenitiy configuration pool and OICD Provider
WIF_POOL="github-pool"
WIF_PROVIDER="github-provider"
CD_SA="cd-deployer"
RUNTIME_SA="mealchemy-backend-runtime"
ENGINE_SA="mealchemy-engine-runtime"
#email gcp use to reference those service accounts
CD_SA_EMAIL="${CD_SA}@${PROJECT_ID}.iam.gserviceaccount.com"
RUNTIME_SA_EMAIL="${RUNTIME_SA}@${PROJECT_ID}.iam.gserviceaccount.com"
ENGINE_SA_EMAIL="${ENGINE_SA}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud config set project "${PROJECT_ID}"
#---------------------------------------------------------------------------------------------

#turn on google cloud api's
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  cloudresourcemanager.googleapis.com

#Artifact registry
# checks if exists, if not creates, otherwise skips
#stores docker images
if ! gcloud artifacts repositories describe "${AR_REPO}" \
    --location="${REGION}" --project="${PROJECT_ID}" &>/dev/null; then
  gcloud artifacts repositories create "${AR_REPO}" \
    --repository-format=docker \
    --location="${REGION}" \
    --description="Mealchemy Docker images"
fi

#Cleanup, keep the 5 most recent image versions, delete older ones.
#help to maintain free storage quota
POLICY_FILE=$(mktemp)
cat > "${POLICY_FILE}" << 'EOF'
[
  {
    "name": "keep-last-5",
    "action": {"type": "Keep"},
    "mostRecentVersions": {"keepCount": 5}
  }
]
EOF
gcloud artifacts repositories set-cleanup-policies "${AR_REPO}" \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --policy="${POLICY_FILE}" \
  --no-dry-run
rm "${POLICY_FILE}"

#Service accounts
#CD_SA is identity that deploys app
#RUNTIME_SA is identity app runs as once deployed
if ! gcloud iam service-accounts describe "${CD_SA_EMAIL}" \
    --project="${PROJECT_ID}" &>/dev/null; then
  gcloud iam service-accounts create "${CD_SA}" \
    --display-name="CD Deployer (GitHub Actions)"
fi

if ! gcloud iam service-accounts describe "${RUNTIME_SA_EMAIL}" \
    --project="${PROJECT_ID}" &>/dev/null; then
  gcloud iam service-accounts create "${RUNTIME_SA}" \
    --display-name="Cloud Run Backend Runtime"
fi

#ENGINE_SA is a separate identity for the engine container.
#It intentionally has no access to db secrets
#engine never touches databse, goes through backend.
if ! gcloud iam service-accounts describe "${ENGINE_SA_EMAIL}" \
    --project="${PROJECT_ID}" &>/dev/null; then
  gcloud iam service-accounts create "${ENGINE_SA}" \
    --display-name="Cloud Run Engine Runtime"
fi

#IAM roles
#this grants access
#CD_SA gets admin, create and update cloud run service and push docker images
#CD_SA starts service and gives permission to RUNTIME_SA
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${CD_SA_EMAIL}" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${CD_SA_EMAIL}" \
  --role="roles/artifactregistry.writer"

gcloud iam service-accounts add-iam-policy-binding "${RUNTIME_SA_EMAIL}" \
  --member="serviceAccount:${CD_SA_EMAIL}" \
  --role="roles/iam.serviceAccountUser"

gcloud iam service-accounts add-iam-policy-binding "${ENGINE_SA_EMAIL}" \
  --member="serviceAccount:${CD_SA_EMAIL}" \
  --role="roles/iam.serviceAccountUser"



#Workload Identity Federation
#how github actions authenticates to GCP without long lived downloadable key
#have a repo check and org check
#essentially github proves everytime, GCP checks against two conditions

#creates the WIF pool, a container for external identity providers
if ! gcloud iam workload-identity-pools describe "${WIF_POOL}" \
    --location="global" --project="${PROJECT_ID}" &>/dev/null; then
  gcloud iam workload-identity-pools create "${WIF_POOL}" \
    --location="global" \
    --display-name="GitHub Actions Pool"
fi

#create wif provider of type OIDC
if ! gcloud iam workload-identity-pools providers describe "${WIF_PROVIDER}" \
    --workload-identity-pool="${WIF_POOL}" \
    --location="global" --project="${PROJECT_ID}" &>/dev/null; then
  gcloud iam workload-identity-pools providers create-oidc "${WIF_PROVIDER}" \
    --location="global" \
    --workload-identity-pool="${WIF_POOL}" \
    --display-name="GitHub Provider" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
    --attribute-condition="assertion.repository_owner == '${GITHUB_ORG}'" \
    --issuer-uri="https://token.actions.githubusercontent.com"
fi

#repo check
gcloud iam service-accounts add-iam-policy-binding "${CD_SA_EMAIL}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL}/attribute.repository/${GITHUB_ORG}/${GITHUB_REPO}"

#Secret Manager, checks then creates
for secret in \
  mealchemy-db-url-prod \
  mealchemy-db-url-staging \
  mealchemy-migrate-url-prod \
  mealchemy-migrate-url-staging \
  mealchemy-db-username-prod \
  mealchemy-db-username-staging \
  mealchemy-db-password-prod \
  mealchemy-db-password-staging \
  mealchemy-jwt-secret; do
  if ! gcloud secrets describe "${secret}" --project="${PROJECT_ID}" &>/dev/null; then
    gcloud secrets create "${secret}" --replication-policy="automatic"
  fi
done

# runtime_sa gets read access to the secrets running app needs at startup
for secret in \
  mealchemy-db-url-prod \
  mealchemy-db-url-staging \
  mealchemy-db-username-prod \
  mealchemy-db-username-staging \
  mealchemy-db-password-prod \
  mealchemy-db-password-staging \
  mealchemy-jwt-secret; do
  gcloud secrets add-iam-policy-binding "${secret}" \
    --project="${PROJECT_ID}" \
    --member="serviceAccount:${RUNTIME_SA_EMAIL}" \
    --role="roles/secretmanager.secretAccessor"
done


#cd_sa gets read access to migrate urls and db username,password
#needed because CI migration job connects to db directly to run Flyway
for secret in \
  mealchemy-migrate-url-prod \
  mealchemy-migrate-url-staging \
  mealchemy-db-username-prod \
  mealchemy-db-username-staging \
  mealchemy-db-password-prod \
  mealchemy-db-password-staging; do
  gcloud secrets add-iam-policy-binding "${secret}" \
    --project="${PROJECT_ID}" \
    --member="serviceAccount:${CD_SA_EMAIL}" \
    --role="roles/secretmanager.secretAccessor"
done

#Populate secrets
#Print statements of instructions to run manually to avoid hardcoded passwords.
#final echo block prints config values for cross checking Ci workflow file

echo ""
echo "Run these commands to populate the secrets:"
echo ""
echo "echo -n 'jdbc:postgresql://ep-super-cloud-asd7d02b-pooler.c-4.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require' | gcloud secrets versions add mealchemy-db-url-prod --data-file=-"
echo "echo -n 'jdbc:postgresql://ep-super-cloud-asd7d02b.c-4.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require' | gcloud secrets versions add mealchemy-migrate-url-prod --data-file=-"
echo "echo -n 'neondb_owner' | gcloud secrets versions add mealchemy-db-username-prod --data-file=-"
echo "echo -n 'YOUR_NEON_PASSWORD_HERE' | gcloud secrets versions add mealchemy-db-password-prod --data-file=-"
echo ""
echo "echo -n 'jdbc:postgresql://ep-bold-tooth-aslv7kax-pooler.c-4.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require' | gcloud secrets versions add mealchemy-db-url-staging --data-file=-"
echo "echo -n 'jdbc:postgresql://ep-bold-tooth-aslv7kax.c-4.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require' | gcloud secrets versions add mealchemy-migrate-url-staging --data-file=-"
echo "echo -n 'neondb_owner' | gcloud secrets versions add mealchemy-db-username-staging --data-file=-"
echo "echo -n 'YOUR_NEON_PASSWORD_HERE' | gcloud secrets versions add mealchemy-db-password-staging --data-file=-"
echo ""
echo "# Generate JWT secret with: openssl rand -base64 48"
echo "echo -n 'YOUR_STRONG_JWT_SECRET_HERE' | gcloud secrets versions add mealchemy-jwt-secret --data-file=-"
echo ""
echo "# JWT_EXPIRATION_MS is not a secret - set as a plain env var in cd.yml"
echo ""
echo "# Firebase Hosting token (landing page deploy, separate from GCP):"
echo "# The landing page deploys to a Firebase project that is not linked to this GCP project."
echo "# Generate a long-lived CI token once and store it as a GitHub Actions secret:"
echo "#   1. Run: npx firebase-tools login:ci"
echo "#   2. Copy the printed token."
echo "#   3. In GitHub: Settings, Secrets, Actions, New secret"
echo "#      Name: FIREBASE_TOKEN   Value: <the token>"
echo ""
echo "cd.yml values (already configured, verify they match):"
echo "  GCP_PROJECT_ID:        ${PROJECT_ID}"
echo "  GCP_PROJECT_NUMBER:    ${PROJECT_NUMBER}"
echo "  GCP_REGION:            ${REGION}"
echo "  AR_REPOSITORY:         ${AR_REPO}"
echo "  WIF_POOL_ID:           ${WIF_POOL}"
echo "  WIF_PROVIDER_ID:       ${WIF_PROVIDER}"
echo "  CD_SA_EMAIL:           ${CD_SA_EMAIL}"
echo "  RUNTIME_SA_EMAIL:      ${RUNTIME_SA_EMAIL}"
echo "  ENGINE_RUNTIME_SA_EMAIL: ${ENGINE_SA_EMAIL}"
