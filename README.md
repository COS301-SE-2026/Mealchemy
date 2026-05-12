# Mealchemy

## Setup Notes

### Prerequisites
- Docker Desktop
- Java 21
- Python 3.12
- Flutter (stable)

### Environment files

Two files must be created before running anything locally, neither is committed to the repo and are already in gitignore.

**`.env`** - Docker credentials (copy from `.env.example`):
```
cp .env.example .env
```
Fill in `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`.

**`.secrets`** — Local CI secrets for `act` (copy from `.secrets.example`):
```
cp .secrets.example .secrets
```
Fill in `DB_USER` and `DB_PASSWORD` (can be anything, these are throwaway values for the local test container).

### Running locally

```bash
# Start postgres + backend
docker compose -f infrastructure/docker-compose.yml --env-file .env up --build

# Start with engine as well
docker compose -f infrastructure/docker-compose.yml --env-file .env --profile engine up --build

# Tear down
docker compose -f infrastructure/docker-compose.yml --env-file .env down
```

Backend health check: `http://localhost:8080/actuator/health`
Engine health check: `http://localhost:8001/health`

### Wiki submodule

After cloning, run:
```bash
git submodule update --init
```
This fetches the wiki content into the `wiki/` folder. The wiki is kept in sync across all branches automatically by the `wiki-sync` workflow.

### Running CI locally

Requires [`act`](https://github.com/nektos/act) and Docker Desktop.

```bash
act pull_request
```
