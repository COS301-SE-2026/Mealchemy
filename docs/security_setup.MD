# Security Setup

This document covers every security measure in place across the Mealchemy repository, from the CI pipeline through to the running containers and the application layer. These are not optional guidelines, they are enforced either by CI failing or by the architecture itself preventing the violation.

---

## 1. Secret Scanning — Gitleaks

Every pull request is scanned for accidentally committed secrets using `gitleaks`. It scans the **entire git history**, not just the latest commit. This means if a password was committed three weeks ago and then removed, gitleaks will still find it.

The scan runs as the first job in `ci.yml` before any tests execute. If a secret is detected the pipeline fails immediately and nothing else runs.

Secrets that are caught include API keys, database passwords, JWT secrets, tokens, and private keys. The scan covers all file types including config files, `.env` files that were accidentally staged, and source code.

The `.env` and `.secrets` files are both listed in `.gitignore`. They must never be committed under any circumstances.

---

## 2. GitHub Actions — SHA Pinning

Every `uses:` action in every workflow file is pinned to a full SHA commit hash rather than a version tag. For example:

```yaml
uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
```

instead of:

```yaml
uses: actions/checkout@v4
```

Version tags like `v4` are mutable. A compromised maintainer or a supply chain attack can redirect `v4` to point at malicious code, and every repository using that tag silently runs the attacker's code on the next pipeline run. A SHA hash is immutable. The exact code that runs in CI today is identical to what will run in six months unless someone deliberately changes the hash in the workflow file.

This applies to every action across `ci.yml`, `deploy-design-spec.yml`, `wiki-sync.yml`, and `pr-labeler.yml`.

---

## 3. Docker Image Scanning — Trivy

Both Docker images (`mealchemy-backend` and `mealchemy-engine`) are scanned with Trivy on every pull request as part of the `docker-security-scan` job. Trivy scans:

- OS packages installed in the image
- Application dependencies (Maven packages for the backend, pip packages for the engine)
- Known CVEs in the base images themselves

The job runs as a matrix so both images are scanned in parallel. It fails the build on any **HIGH** or **CRITICAL** severity vulnerability. Medium and low severity findings are reported but do not fail the build.

If Trivy flags a vulnerability, the fix is to update the affected dependency or base image and push a new commit. Do not suppress Trivy findings without a documented reason.

---

## 4. Non-Root Container Users

Both Docker images run the application as a non-root system user named `mealchemy`. The user is created inside the Dockerfile and the application process is started as that user.

Running containers as root means a process that escapes the container has full root access to the host machine. Running as a non-root user limits this. If any container escapes or application exploits this, it is limited to only what the `mealchemy` user is allowed to do, which is nothing outside the application directory.

This applies to both the Spring Boot backend container and the Python engine container.

---

## 5. Container Resource Limits

Every service in `docker-compose.yml` has explicit CPU and memory resource limits. This prevents a single leaking or runaway container from consuming all available resources on the host machine and taking down the entire local stack.

This is a defence-in-depth measure. A memory leak in the backend or the engine cannot cascade into killing the Postgres container or starving the host OS of resources.

---

## 6. Environment Variable Injection — No Hardcoded Credentials

No password, secret key, API key, connection string, or token is hardcoded anywhere in the codebase. All credentials are injected at runtime through environment variables.

| Environment | How credentials are injected |
|---|---|
| Local Docker | `.env` file passed via `--env-file .env` |
| Local act CI | `.secrets` file loaded via `--secret-file .secrets` |
| GitHub Actions CI | GitHub repository Secrets |
| Render (production) | Render environment variable dashboard |

The `${VAR:fallback}` syntax in `application.properties` means the app uses the environment variable if set and falls back to a local default otherwise. The local defaults only work on localhost and are useless in any other environment.

Violating this rule is treated as a critical security incident where keys will be rotated if violated.

---

## 7. JWT Authentication

All protected API endpoints require a valid JWT token. The token is issued on login and must be sent with every subsequent request in the `Authorization: Bearer <token>` header.

Key properties of the JWT implementation:

| Property | Value |
|---|---|
| Algorithm | HS256 |
| Expiry | 24 hours |
| Secret key | Minimum 32 characters, stored in environment variable only |
| Payload contents | `userId` and expiry only |

The JWT secret is never committed to source code. It is read from the `JWT_SECRET` environment variable at runtime.

The token payload contains only the `userId` and expiry time. No roles, emails, or other user data are stored in the token. Roles are fetched fresh from the database on each authenticated request, which means a role change takes effect immediately without waiting for a token to expire.

The `JwtAuthFilter` runs before every controller method. It reads the `Authorization` header, validates the signature and expiry, and registers the authenticated user with Spring Security. If the token is missing, malformed, or expired, the request is not blocked at the filter level but Spring Security will reject it at the endpoint if authentication is required.

---

## 8. Password Hashing - BCrypt

User passwords are hashed using BCrypt with a cost factor of 12 before being stored in the database. Plaintext passwords are never stored anywhere.

BCrypt cost factor 12 means the hashing operation is intentionally slow, making brute-force and rainbow table attacks computationally expensive. The higher the cost factor, the slower each guess attempt is.

Password hashes are excluded from every DTO and every API response. The `passwordHash` field never leaves the backend.


## 9. Stateless Backend — No Server Sessions

The Spring Boot backend is fully stateless. Authentication state lives entirely in the JWT token. There are no server-side sessions, no in-memory user state, and no session cookies.

Spring Security is configured with `SessionCreationPolicy.STATELESS` which disables session creation entirely. CSRF protection is also disabled because CSRF attacks target session-based authentication and are not applicable to token-based stateless APIs.



## 10. Database Security

### Flyway Owns the Schema

`ddl-auto=validate` is set in `application.properties`. JPA never creates, alters, or drops tables. Flyway runs migrations. Hibernate only checks that entity classes match the schema at startup.

Setting `ddl-auto=create` or `ddl-auto=update` is not enabled. These modes let Hibernate modify the database schema, which diverges the schema from the migration history and makes the database impossible to reproduce reliably.

### Sensitive Data Never Leaves

Password hashes, internal flags, and soft-delete timestamps are never included in any API response. The DTOs that cross the network boundary are the only thing Flutter ever sees.

---

## 11. Principle of Least Privilege - Summary

The least privilege principle is applied at every layer:

| Layer | How it is applied |
|---|---|
| Docker containers | Run as non-root `mealchemy` user |
| Database user | No superuser, only required permissions |
| GitHub Personal Access Token for CI | Contents: Read-only|
| JWT payload | Only `userId` and expiry, no sensitive data |
| API responses | DTOs only, not raw entities |
| Engine | No database access, API calls only |
