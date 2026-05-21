# Act Setup

## What is act

`act` is a command line tool that runs GitHub Actions workflows locally inside Docker containers. Instead of pushing code to GitHub every time you want to check if the pipeline passes, you run `act` on your machine and get the same result in minutes without touching the remote repository.

For Mealchemy, `act` mirrors the full `ci.yml` pipeline locally. You can run the entire pipeline, a single job, or just lint before committing.

## How it works

`act` reads the workflow files in `.github/workflows/`, spins up Docker containers that mimic GitHub's runner environment, and executes each job inside them. It uses a pre-built Ubuntu image that already has Java, Python, Node, and Docker installed so most jobs work without any extra setup.

Secrets that GitHub Actions would normally read from the repository's secret store are instead read from a local `.secrets` file on your machine.

## Prerequisites

Docker Desktop must be running before using `act`. If Docker is not running, `act` will fail immediately.

## Installing act

Install act on your device

## First-time setup

Copy the secrets template and fill in your values:

```bash
cp .secrets.example .secrets
```

Open `.secrets` and fill in:

```
DB_USER=mealchemy_ci
DB_PASSWORD=mealchemy_ci_pass
GITHUB_TOKEN=your_github_pat_here

```

The `.secrets` file is git-ignored.

## Running the pipeline

### Full pipeline (mirrors a GitHub PR)

```bash
act pull_request
```

### Single jobs

```bash
act pull_request -j backend-lint
act pull_request -j backend-unit-tests
act pull_request -j backend-integration-tests
act pull_request -j engine-lint
act pull_request -j engine-typecheck
act pull_request -j engine-tests
act pull_request -j frontend-analyze
act pull_request -j frontend-tests
act pull_request -j docker-security-scan
```

### Utilities

```bash
# List all jobs without running anything
act pull_request --list

# Show the execution plan without running
act pull_request --dry-run
```

## Configuration

The `.actrc` file in the repo root configures `act` automatically. You do not need to pass these flags manually every time:

| Flag | Why it is set |
|---|---|
| `--platform ubuntu-latest=catthehacker/ubuntu:act-22.04` | image with Java, Python, Node, and Docker already installed |
| `--secret-file .secrets` | Loads local secrets so act has the same values as real CI |
| `--container-options --privileged` | Required for Postgres service containers and Trivy |
| `--container-architecture linux/amd64` | Forces AMD64 images on Apple M-series Macs since GitHub runners are AMD64 |


## What runs locally vs on GitHub

Some jobs are skipped locally.

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

Jobs are skipped locally using `if: ${{ env.ACT != 'true' }}` in the workflow file. `act` automatically sets the `ACT` environment variable to `true` when running.

## Known issues unrelating to implementation

**Post-step cleanup errors:** After jobs finish, `act` sometimes prints `node not found` errors during the cleanup phase. This is a known `act` issue and is cosmetic only. All jobs ran correctly if the job itself showed as passed.

**Apple Silicon:** `act` downloads AMD64 images on M-series Macs. Flutter is downloaded fresh on each run via the setup action. This is slower than on a real GitHub runner but works correctly.

**Exit after cleanup error:** If `act` exits with a post-cleanup error, check the terminal output above it. If all test steps show as passed, the run was successful.
