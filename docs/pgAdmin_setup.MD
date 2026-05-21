# pgAdmin Setup

## What is pgAdmin

pgAdmin is a browser-based interface for viewing and querying a PostgreSQL database. 

For Mealchemy, pgAdmin connects to the local Postgres container running in Docker. It is useful for checking whether Flyway migrations ran correctly, inspecting seed data, debugging queries, and verifying that data is being written as expected during development.

## How it works

pgAdmin runs as a Docker container alongside the other services. It is behind the `tools` profile in `docker-compose.yml`, which means it does not start unless you explicitly include `--profile tools` in the Docker command.

Once running, pgAdmin is available at `http://localhost:5050` in your browser. You log in with credentials from your `.env` file and then manually register a server connection pointing at the `postgres` container.

The host for the connection is `postgres`, not `localhost`. This is because pgAdmin and Postgres are both inside the Docker network, where services talk to each other by their service name. From inside the Docker network, `localhost` refers to the pgAdmin container itself, not Postgres.

## Prerequisites

The Docker stack must be running with the `tools` profile. Make sure you have already done the Docker setup and that your `.env` file is filled in.

## Starting pgAdmin

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env --profile tools up --build
```

If you also want the backend running at the same time:

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env --profile tools up --build
```

The backend is part of the default profile so it starts automatically alongside pgAdmin.

Once the containers are up, open your browser and go to:

```
http://localhost:5050
```

## Logging in to pgAdmin

Use the credentials from your `.env` file:

| Field | Value |
|---|---|
| Email | Value of `PGADMIN_EMAIL` in your `.env` |
| Password | Value of `PGADMIN_PASSWORD` in your `.env` |

The defaults in `.env.example` are:

```
PGADMIN_EMAIL=admin@mealchemy.dev
PGADMIN_PASSWORD=changeme
```

Change these in your local `.env` if you want. They only apply to your machine.

## Registering the database connection

The first time you open pgAdmin after a fresh Docker volume, you need to manually tell it how to connect to the Postgres container. This is a one-time step. pgAdmin saves the connection in its own volume so you will not need to do it again unless you wipe the pgAdmin volume with `down -v`.

1. In the pgAdmin sidebar, right-click **Servers**
2. Select **Register > Server**
3. Fill in the **General** tab:

| Field | Value |
|---|---|
| Name | `Mealchemy Dev` |

4. Click the **Connection** tab and fill in:

| Field | Value |
|---|---|
| Host | `postgres` |
| Port | `5432` |
| Maintenance database | Value of `POSTGRES_DB` in your `.env` (default: `mealchemy_dev`) |
| Username | Value of `POSTGRES_USER` in your `.env` (default: `mealchemy_user`) |
| Password | Value of `POSTGRES_PASSWORD` in your `.env` |

5. Click **Save**

The server should appear in the sidebar and show a green connected indicator.

## Browsing the database

Once connected, expand the tree in the left sidebar:

```
Servers
  Mealchemy Dev
    Databases
      mealchemy_dev
        Schemas
          public
            Tables
```

Right-click any table and select **View/Edit Data > All Rows** to see its contents. You can also open the **Query Tool** from the **Tools** menu to run raw SQL.

```

## Stopping pgAdmin

When you stop the Docker stack, pgAdmin stops too:

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env --profile tools down
```

The pgAdmin configuration (saved server connections, query history) persists in the `pgadmin_data` Docker volume. It will be there when you start it again.

To wipe everything including the pgAdmin config:

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env --profile tools down -v
```

After this you will need to re-register the server connection.

## pgAdmin does not start

If pgAdmin fails to start or the browser shows nothing at `http://localhost:5050`, check the container logs:

```bash
docker logs mealchemy-pgadmin
```

Common causes:
- The `tools` profile was not included in the docker compose command
- The `PGADMIN_EMAIL` or `PGADMIN_PASSWORD` values in `.env` are missing
- Port 5050 is already in use by another process on your machine
