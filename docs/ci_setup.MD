# CI Setup

## What is CI

CI stands for Continuous Integration. It is a GitHub Actions pipeline that runs automatically on every pull request. Its job is to catch broken code before it gets merged into `dev` or `main`. Every push to a PR triggers the full pipeline and nothing merges unless all jobs pass.

The pipeline is defined in `.github/workflows/ci.yml`.

## How it works

When you open or push to a pull request, GitHub spins up a runner (a temporary Ubuntu machine) and runs a series of jobs in parallel where possible, and in sequence where one job depends on another.

The jobs run in this order:

```
secret-scan
    backend-lint
        backend-unit-tests
            backend-integration-tests
    engine-lint
        engine-typecheck
            engine-tests
    frontend-analyze
        frontend-tests
    docker-security-scan
```

Each job only starts if the one before it passed. This means a lint failure stops the tests from running, giving you fast feedback without wasting CI minutes.

## Jobs explained

### secret-scan

Runs `gitleaks` across the entire git history looking for accidentally committed secrets (API keys, passwords, tokens). It scans every commit, not just the latest one.

This job is skipped when running locally with `act` because it makes real GitHub API calls that fail outside the GitHub environment.

### backend-lint

Runs Checkstyle against Google Java style rules:

```bash
./mvnw checkstyle:check
```

Any style violation fails the build. The same rules run in VS Code via the Checkstyle extension so you should see violations inline before pushing.

### backend-unit-tests

Runs only the unit tests. No database is needed for this job.

```bash
./mvnw test -Dtest="*UnitTest" -DfailIfNoTests=true
```

Any test class whose name ends in `UnitTest` is included. These run fast.

### backend-integration-tests

Spins up a real PostgreSQL 16 container as a service, runs Flyway migrations against it, then runs all tests including integration tests.

```bash
./mvnw verify -DfailIfNoTests=true
```

JaCoCo generates a coverage report after this job. It enforces:
- 80% instruction coverage
- 80% branch coverage
- 80% method coverage

Every non-excluded class must have at least one covered line. The coverage report is uploaded to Codecov.

Excluded from coverage measurement: `MealchemyApplication`, Spring configuration classes, JPA entity classes, and placeholder feature packages. Remove the exclusion in `pom.xml` when a feature gets real code and tests.

### engine-lint

Runs Ruff on all Python files:

```bash
ruff check src/ tests/
```

Ruff checks for style issues and correctness problems. It is fast and catches things like unused imports and undefined names.

### engine-typecheck

Runs Mypy with strict mode:

```bash
mypy src/ --strict
```

Strict means every function must have type annotations and no implicit `Any` types are allowed. This catches type errors before they become runtime bugs in the recommendation algorithm.

### engine-tests

Runs pytest with coverage:

```bash
pytest tests/ -v --cov=src --cov-report=xml:coverage.xml --cov-fail-under=80
```

Fails if coverage drops below 80%. The coverage report is uploaded to Codecov.

-----

### frontend-analyze

Runs the Dart analyser:

```bash
flutter analyze
```

Checks all Dart code against the rules in `analysis_options.yaml`. No analysis errors may be suppressed without a comment explaining why.

-----


### frontend-tests

Runs Flutter tests with coverage:

```bash
flutter test --coverage
```

Generated files (`.g.dart` and `.freezed.dart`) are stripped from the coverage report using `lcov`. A script then checks that line coverage is at or above 80%. The result is uploaded to Codecov.

***Why Flutter uses a custom Python script for coverage***

Flutter generates `coverage/lcov.info` when you run `flutter test --coverage`, but this file
includes auto-generated files like `.g.dart` and `.freezed.dart` (produced by `build_runner`
for JSON serialisation and immutable models). These are not written by the team and should
not count toward the coverage percentage. Flutter has no built-in flag to exclude them.

The standard fix is using the `lcov` CLI tool with `--remove`, but that requires installing
it on every CI run and it is not available on all runner images by default.

The Python script handles both problems in one step. It reads `coverage/lcov.info` and drops
any record block matching `*.g.dart` or `*.freezed.dart`, rewrites the cleaned file in place,
tallies `LF:` (lines found) and `LH:` (lines hit) across all remaining records, then exits
with a non-zero code if coverage is below 80%. That non-zero exit is what fails the CI job.

Python is already available on every GitHub Actions runner so nothing extra needs to be
installed. This keeps the threshold consistent with how the backend (JaCoCo) and engine
(pytest-cov) enforce the same 80% requirement. This also speeds up the CI checks.

-----------

### docker-security-scan

Builds both Docker images and scans them with Trivy. Fails on any HIGH or CRITICAL vulnerability found in the image layers or installed packages.

This job runs as a matrix so both images are scanned in parallel. It is skipped when running locally with `act` because Docker-in-Docker is not supported in that environment.

-----

## GitHub Secrets required for CI

These must be set in the repository under **Settings > Secrets and variables > Actions**:

| Secret | What it is |
|---|---|
| `DB_USER` | Postgres username for the integration test container |
| `DB_PASSWORD` | Postgres password for the integration test container |


`GITHUB_TOKEN` is provided automatically by GitHub Actions on every run. You do not need to set it manually.

## Supply chain security

Every `uses:` action in `ci.yml` is pinned to a full SHA commit hash rather than a version tag. For example:

```yaml
uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
```

This prevents a scenario where someone redirects a tag like `v4` to malicious code. Pinning to a SHA means the exact code that runs in CI can never change without a deliberate update to the workflow file.

## What runs locally vs on GitHub

| Job | act (local) | GitHub |
|---|---|---|
| All lint jobs | Runs | Runs |
| Unit tests | Runs | Runs |
| Integration tests | Runs | Runs |
| JaCoCo coverage | Runs | Runs |
| pytest coverage | Runs | Runs |
| Flutter coverage | Runs | Runs |
| Codecov uploads | Skipped | Runs |
| Trivy scan | Skipped | Runs |
| gitleaks | Skipped | Runs |

Jobs skipped in `act` are conditional on `if: ${{ env.ACT != 'true' }}`.

## Test naming convention

The CI pipeline distinguishes test types purely by class name suffix. Getting this wrong puts tests in the wrong job and skews coverage data.

| Suffix | Job | Database |
|---|---|---|
| `UnitTest` | `backend-unit-tests` | None |
| `IntegrationTest` | `backend-integration-tests` | Real PostgreSQL |

A unit test that boots a Spring context is mislabelled. A unit test that hits the database is also mislabelled. Keep them separate.

## Coverage thresholds

80% is enforced across all three services. These are hard gates that fail the build.

| Service | Tool | Threshold |
|---|---|---|
| Backend | JaCoCo | 80% instruction, branch, method |
| Engine | pytest-cov | 80% line |
| Frontend | lcov | 80% line |

New code introduced in a PR must also meet 80% on changed lines. Codecov enforces this as a PR status check.
