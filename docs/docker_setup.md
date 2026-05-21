# Docker Setup

## What is Docker

Docker is a tool that packages an application and everything it needs to run (dependencies, config, runtime) into a container. A container behaves the same on every machine. If it runs in Docker, it runs the same way for every teammate and in CI.

For Mealchemy, Docker runs the entire backend stack locally: PostgreSQL, the Spring Boot backend, the Python engine, and pgAdmin. You do not need to install Postgres or Java globally. Docker handles all of it.

## How it works

The `infrastructure/` folder contains two Dockerfiles and one `docker-compose.yml`.

The Dockerfiles describe how to build each service image:
- `Dockerfile.backend` builds the Spring Boot JAR using a two-stage build. Stage one compiles with the full JDK. Stage two runs the compiled JAR using only a minimal JRE, keeping the final image smaller.
- `Dockerfile.engine` builds the Python engine the same way. Stage one installs dependencies. Stage two copies only what is needed to run.

`docker-compose.yml` wires all the services together. It defines four services:

| Service | Image | Host Port | Purpose |
|---|---|---|---|
| `postgres` | `postgres:16` | `5432` | The database |
| `backend` | Built from `Dockerfile.backend` | `8080` | Spring Boot API |
| `engine` | Built from `Dockerfile.engine` | `8001` | Python recommendation engine |
| `pgadmin` | `dpage/pgadmin4:8` | `5050` | Browser-based DB viewer |

The engine and pgAdmin are behind Docker profiles so they do not start by default. This keeps the default startup fast since most work only needs Postgres and the backend.

Services use `depends_on: condition: service_healthy` so the backend will not start until Postgres has passed its health check. This prevents the race condition where the backend starts before the database is ready.

All credentials come from the `.env` file. Nothing is hardcoded.

## Prerequisites

Install Docker Desktop. Make sure it is running before using any of the commands below.

## First-time setup

Copy the environment template and fill in your credentials:

```bash
cp .env.example .env
```

Open `.env` and set values for:

These values are examples:

```

POSTGRES_DB = mealchemy_dev_example
POSTGRES_USER = mealchemy_user_example
POSTGRES_PASSWORD = your_password_here
PGADMIN_EMAIL = email_example@mealchemy.dev
PGADMIN_PASSWORD = your_pgadmin_password_here
```

The `.env` file is git-ignored.

## Starting the stack

### Default (Postgres + Backend only)

The main command that gets used:

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env up --build
```

### With pgAdmin (browser DB viewer)

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env --profile tools up --build
```

### With the Python engine

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env --profile engine up --build
```

### Everything (Postgres + Backend + Engine + pgAdmin)

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env --profile engine --profile tools up --build
```

## Stopping the stack

### Stop but keep the database volume

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env --profile engine --profile tools down
```

### Stop and wipe the database (full reset)

Only do this if you want to start from a completely clean database. This is destructive and cannot be undone.

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env --profile engine --profile tools down -v
```

## Checking container status

```bash
docker ps
```

This shows all running containers, their ports, and their health status.

## Health checks

Once the stack is running, verify each service:

```bash
# Backend
curl http://localhost:8080/actuator/health
# Expected: {"status":"UP"}

# Engine
curl http://localhost:8001/health
# Expected: {"status":"UP"}

# pgAdmin
# Open http://localhost:5050 in your browser
```

## Building images individually

Run these from the repo root if you need to build a single image without docker compose:

```bash
docker build -f infrastructure/Dockerfile.backend -t mealchemy-backend .
docker build -f infrastructure/Dockerfile.engine -t mealchemy-engine .
```

## Environment variables

The `.env` file is used by Docker Compose. The `.secrets` file is separate and used only by `act` for local CI runs.

| File | Used by | Contains |
|---|---|---|
| `.env` | Docker Compose | Postgres and pgAdmin credentials |
| `.secrets` | act (local CI) | CI database credentials and GitHub token |

Both files are git-ignored. Templates are provided as `.env.example` and `.secrets.example`.

## Notes on the two-stage Docker builds

The backend Dockerfile copies `pom.xml` and the Maven wrapper first before copying the source code. This is intentional. Docker caches each layer. If `pom.xml` has not changed, Docker reuses the cached dependency download layer and skips re-downloading all dependencies on every build. This makes rebuilds significantly faster.

Both images run the application as a non-root user called `mealchemy`. Running containers as root is a security risk and is not permitted.

Both images have CPU and memory resource limits defined in `docker-compose.yml`. This prevents a leaking container from consuming all resources on your machine when running the full stack locally.
