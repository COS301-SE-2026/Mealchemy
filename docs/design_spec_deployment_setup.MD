# Design Spec Deployment Setup

## What is the design spec

The design spec is a static website that hosts the Mealchemy brand style guide and wireframes. It lives in the `design-spec/` folder at the repo root. The site is automatically published to GitHub Pages so anyone on the team or the client can view the latest design documentation in a browser without needing to clone the repo or open any files locally.

The live site is available at:

```
https://cos301-se-2026.github.io/Mealchemy/
```

## How it works

The `deploy-design-spec.yml` workflow in `.github/workflows/` handles deployment. It triggers automatically when changes are pushed to `main` or `dev` that touch anything inside `design-spec/`. It can also be triggered manually from the GitHub Actions tab at any time.

The workflow uses GitHub's OIDC token (keyless authentication) to publish directly to GitHub Pages without needing a stored secret or a deploy key.


