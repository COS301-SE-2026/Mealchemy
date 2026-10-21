<div align="center">

<img src="docs/photo_documentation/logo-full-primary.png" alt="Mealchemy logo" width="320"/>
<img src="docs/photo_documentation/EPI-USE-Labs-logo.jpg" alt="EPI-USE Labs logo" width="320"/>

# Mealchemy

**Turn what's in your pantry into what's on your plate.**

An intelligent recipe management and discovery ecosystem, built by Team PUL5E.

[![Watch the Demo](https://img.shields.io/badge/▶%20%20WATCH%20THE%20DEMO-D4AF37?style=for-the-badge&labelColor=570013)](https://youtu.be/P83dsDzIkEM)
[![Android App](https://img.shields.io/badge/📱%20%20ANDROID%20APP-A8003A?style=for-the-badge&labelColor=570013)](https://appdistribution.firebase.dev/i/3d354d60d11cde9b)
[![Landing Page](https://img.shields.io/badge/🌐%20%20LANDING%20PAGE-5C0018?style=for-the-badge&labelColor=570013)](https://mealchemy-firebase.web.app/)
[![Wiki](https://img.shields.io/badge/📖%20%20WIKI-1D1C17?style=for-the-badge&labelColor=570013)](https://github.com/COS301-SE-2026/Mealchemy/wiki)

<br/>

[![Coverage Overall](https://codecov.io/gh/COS301-SE-2026/Mealchemy/branch/main/graph/badge.svg?token=GRHIRNQ260)](https://codecov.io/gh/COS301-SE-2026/Mealchemy)
[![Coverage Backend](https://codecov.io/gh/COS301-SE-2026/Mealchemy/branch/main/graph/badge.svg?token=GRHIRNQ260&flag=backend)](https://codecov.io/gh/COS301-SE-2026/Mealchemy)
[![Coverage Frontend](https://codecov.io/gh/COS301-SE-2026/Mealchemy/branch/main/graph/badge.svg?token=GRHIRNQ260&flag=frontend)](https://codecov.io/gh/COS301-SE-2026/Mealchemy)
[![CI](https://github.com/COS301-SE-2026/Mealchemy/actions/workflows/ci.yml/badge.svg)](https://github.com/COS301-SE-2026/Mealchemy/actions/workflows/ci.yml)
[![CD](https://github.com/COS301-SE-2026/Mealchemy/actions/workflows/cd.yml/badge.svg)](https://github.com/COS301-SE-2026/Mealchemy/actions/workflows/cd.yml)
[![Frontend Delivery](https://github.com/COS301-SE-2026/Mealchemy/actions/workflows/frontend-delivery.yml/badge.svg)](https://github.com/COS301-SE-2026/Mealchemy/actions/workflows/frontend-delivery.yml)
[![Deploy Landing Page](https://github.com/COS301-SE-2026/Mealchemy/actions/workflows/deploy-landing-page.yml/badge.svg?branch=main)](https://github.com/COS301-SE-2026/Mealchemy/actions/workflows/deploy-landing-page.yml)
[![Deploy Design Spec](https://github.com/COS301-SE-2026/Mealchemy/actions/workflows/deploy-design-spec.yml/badge.svg)](https://github.com/COS301-SE-2026/Mealchemy/actions/workflows/deploy-design-spec.yml)
[![API uptime](https://img.shields.io/website?url=https%3A%2F%2Fmealchemy-backend-prod-otygypdv7a-ey.a.run.app%2Factuator%2Fhealth&label=API%20uptime)](https://stats.uptimerobot.com/wnmHUXyJfN)
[![Issues](https://img.shields.io/github/issues/COS301-SE-2026/Mealchemy)](https://github.com/COS301-SE-2026/Mealchemy/issues)

<br/>

<h3>App Trailer</h3>

<a href="https://youtube.com/shorts/SEP7DQe_GJk">
  <img src=docs/photo_documentation/trailer-thumbnail.png alt="Watch the Mealchemy app trailer"/>
</a>

<sub>▶ Click to watch the trailer on YouTube</sub>

</div>

---

## About

Mealchemy eliminates meal-time indecision by transforming your available ingredients into personalised, shoppable culinary experiences. It is both a **digital recipe vault** and an **intelligent discovery engine**, bridging the gap between what is in your pantry and what ends up on your plate.

| Before Mealchemy | With Mealchemy |
|:---|:---|
| "What can I make with what I have?" | Your pantry answers it, with a match % on every recipe |
| Recipes scattered across tabs, screenshots and notes | One organised vault, private or shared |
| Missing an ingredient halfway through cooking | Shopping lists built from what's missing |
| Generic suggestions | Recommendations tuned to your taste and dietary profile |

<br/>

## Features

- **Swipe discovery:** swipe through one recipe at a time, filter by Quick Meals, High Protein or Vegetarian, and see why each recipe matches you (pantry match, freshness, cuisine, nutritional goals). Recommendations adapt to your likes, dislikes and skips.
- **Sizzles:** short cooking videos you can swipe through, open as a full recipe, or save.
- **Personal profile:** dietary restrictions, allergies, disliked ingredients, flavour preferences, nutritional goals, cooking equipment and metric or imperial units shape every recommendation.
- **Recipe vault:** create your own recipes with photo or video, organise them in folders, save external links, and publish to the community vault.
- **Shared vaults:** collaborate with Owner, Editor and Viewer roles, email invitations, edit locking and an in-app notification inbox.
- **Pantry tracking:** an ingredient inventory with categories, search and freshness status.
- **Shopping lists:** generate lists from recipes or meal plans, add items manually, and push purchased items to your pantry. Smart add lists only what you do not already own.
- **Meal planning:** plan recipes by date and timeslot, get pantry-aware suggestions, and shop for a whole date range.
- **Hands-free cooking:** step-by-step cooking mode with read-aloud steps, voice commands ("next", "back", "repeat"), adjustable speed and multiple named timers.
- **Recipe detail and nutrition:** prep and cook time, adjustable servings, and calories, macros and per-ingredient nutrients, per recipe or per serving.
- **Community moderation:** report recipes in the community vault, with moderators reviewing, removing or dismissing flags.
- **Offline mode:** browse cached vaults, recipes, pantry, shopping lists and Discover content with a "last synced" indicator.

<br/> 

## Architecture

```mermaid
flowchart LR
    A["Flutter App"] -->|REST + OpenAPI| B["Spring Boot API<br/>Java 21"]
    B --> C[("PostgreSQL 16<br/>Flyway migrations")]
    B <-->|recommendations| D["Recommendation Engine<br/>Python 3.12"]
    D --> C
    E["GitHub Actions"] -->|CI / CD| F["Google Cloud Run<br/>staging + production"]
    B -.runs on.-> F
    G["Uptime Robot"] -.monitors.-> F
```

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-6DB33F?style=flat&logo=springboot&logoColor=white)
![Java](https://img.shields.io/badge/Java_21-ED8B00?style=flat&logo=openjdk&logoColor=white)
![Python](https://img.shields.io/badge/Python_3.12-3776AB?style=flat&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL_16-4169E1?style=flat&logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat&logo=githubactions&logoColor=white)

More detail: [Architectural Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Architectural-Requirements-Demo-4) · [Technology Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Technology-Requirements-Demo-4) · [Deployment](https://github.com/COS301-SE-2026/Mealchemy/wiki/Deployment-Demo-4) · [API Contracts](https://github.com/COS301-SE-2026/Mealchemy/wiki/API-Service-Contracts-Demo-4)

<br/>

## Quality and testing

| Practice | Where to look |
|:---|:---|
| CI/CD with separate CI, CD, frontend-delivery, landing-page and design-spec workflows | [`.github/workflows`](.github/workflows) |
| Code coverage split into backend and frontend flags | [`Codecov`](https://codecov.io/gh/COS301-SE-2026/Mealchemy) |
| Static analysis | [`sonar-project.properties`](sonar-project.properties) |
| Performance and resilience: k6 load, resilience and comparison tests | [`nfr-tests/performance`](nfr-tests/performance) |
| Security: authorization matrix and OWASP ZAP tooling | [`nfr-tests/security`](nfr-tests/security) |
| End-to-end mobile flows with Maestro | [`e2e/`](e2e) |
| Live production uptime monitoring | [`Status page`](https://stats.uptimerobot.com/wnmHUXyJfN) |

<br/>

## Quick Links

| Resource | Link |
|:---|:---|
| Demo video | [Watch](https://youtu.be/P83dsDzIkEM) |
| GitHub Project Board | [Project Board](https://github.com/orgs/COS301-SE-2026/projects/67) |
| Wiki (all documentation) | [Wiki Home](https://github.com/COS301-SE-2026/Mealchemy/wiki) |
| Backend (production) | [mealchemy-backend-prod](https://mealchemy-backend-prod-otygypdv7a-ey.a.run.app) |
| Backend (staging) | [mealchemy-backend-staging](https://mealchemy-backend-staging-otygypdv7a-ey.a.run.app) |
| Uptime status page | [Production monitor](https://stats.uptimerobot.com/wnmHUXyJfN) |
| Landing page | [mealchemy-firebase.web.app](https://mealchemy-firebase.web.app/) |
| Android app | [Download](https://appdistribution.firebase.dev/i/3d354d60d11cde9b) |
| Brand style guide | [Brand Guide](https://cos301-se-2026.github.io/Mealchemy/) |
| Service contracts | [OpenAPI / Swagger](https://mealchemy-backend-staging-otygypdv7a-ey.a.run.app/swagger-ui/index.html#/vault-controller/getVault) |
| Team email | [pulsefive@gmail.com](mailto:pulsefive@gmail.com) |

<br/>

## Documentation

All documentation is contained within the [Wiki](https://github.com/COS301-SE-2026/Mealchemy/wiki).

<details>
  <summary>Demo 4 (latest) - Click to expand</summary>

### Software Requirements Specifications (SRS)

| Page | Description |
|------|-------------|
| [Introduction](https://github.com/COS301-SE-2026/Mealchemy/wiki/SRS-Introduction-Demo-4) | Project background, motivation, and scope |
| [User Stories](https://github.com/COS301-SE-2026/Mealchemy/wiki/User-Stories-and-Characteristics-Demo-4) | Intended users and how they interact with the system |
| [Use Cases](https://github.com/COS301-SE-2026/Mealchemy/wiki/Use-Cases-Demo-4) | High-level use case diagrams and descriptions |
| [Functional Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Functional-Requirements-Demo-4) | Feature breakdown by subsystem |
| [Non-Functional Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Non‐Functional-Requirements-Demo-4) | Feature breakdown by subsystem |
| [Domain Model](https://github.com/COS301-SE-2026/Mealchemy/wiki/Domain-Model-Demo-4) | UML class diagram |

### Software Architecture Specifications (SAS)

| Page | Description |
|------|-------------|
| [Introduction](https://github.com/COS301-SE-2026/Mealchemy/wiki/SAS-Introduction-Demo-4) | Project background, motivation, and scope |
| [Architectural Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Architectural-Requirements-Demo-4) | Intended users and how they interact with the system |
| [Technology Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Technology-Requirements-Demo-4) | Technology Requirements |
| [API Service Contracts](https://mealchemy-backend-staging-otygypdv7a-ey.a.run.app/swagger-ui/index.html#/vault-controller/getVault) | API Contracts - OpenAPI Swagger Schema |
| [Deployment](https://github.com/COS301-SE-2026/Mealchemy/wiki/Deployment-Demo-4) | Deployment |

### Other Documents

| Page | Description |
|------|-------------|
| [Coding Standards Document](https://github.com/COS301-SE-2026/Mealchemy/wiki/Coding-Standards-Document-Demo-4) | Code style conventions and repository structure guidelines |
| [User Manual](https://github.com/COS301-SE-2026/Mealchemy/wiki/User-Manual-Document-Demo-4) | How to use the app - screenshots and feature walkthroughs |
| [Testing Policy Document](https://github.com/COS301-SE-2026/Mealchemy/wiki/Testing-Policy-Document-Demo-4) | Testing standards, types, tools, and responsibilities |
| [Changelog](https://github.com/COS301-SE-2026/Mealchemy/wiki/Changelog-Demo-4) | Version history and what changed each demo |

</details>

<details>
  <summary>Demo 3 - Click to expand</summary>

### Software Requirements Specifications (SRS)

| Page | Description |
|------|-------------|
| [Introduction](https://github.com/COS301-SE-2026/Mealchemy/wiki/SRS-Introduction-Demo-3) | Project background, motivation, and scope |
| [User Stories](https://github.com/COS301-SE-2026/Mealchemy/wiki/User-Stories-and-Characteristics-Demo-3) | Intended users and how they interact with the system |
| [Use Cases](https://github.com/COS301-SE-2026/Mealchemy/wiki/Use-Cases-Demo-3) | High-level use case diagrams and descriptions |
| [Functional Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Functional-Requirements-Demo-3) | Feature breakdown by subsystem |
| [Non-Functional Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Non‐Functional-Requirements-Demo-3) | Feature breakdown by subsystem |
| [Domain Model](https://github.com/COS301-SE-2026/Mealchemy/wiki/Domain-Model-Demo-3) | UML class diagram |



### Software Architecture Specifications (SAS)

| Page | Description |
|------|-------------|
| [Introduction](https://github.com/COS301-SE-2026/Mealchemy/wiki/SAS-Introduction-Demo-3) | Project background, motivation, and scope |
| [Architectural Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Architectural-Requirements-Demo-3) | Intended users and how they interact with the system |
| [Technology Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Technology-Requirements-Demo-3) | Technology Requirements |
| [API Service Contracts](https://github.com/COS301-SE-2026/Mealchemy/wiki/API-Service-Contracts-Demo-3) | API Contracts |
| [Deployment](https://github.com/COS301-SE-2026/Mealchemy/wiki/Deployment-Demo-3) | Deployment |

### Other Documents

| Page | Description |
|------|-------------|
| [Coding Standards Document](https://github.com/COS301-SE-2026/Mealchemy/wiki/Coding-Standards-Document-Demo-3) | Code style conventions and repository structure guidelines |
| [User Manual](https://github.com/COS301-SE-2026/Mealchemy/wiki/User-Manual-Document-Demo-3) | How to use the app - screenshots and feature walkthroughs |
| [Testing Policy Document](https://github.com/COS301-SE-2026/Mealchemy/wiki/Testing-Policy-Document-Demo-3) | Testing standards, types, tools, and responsibilities |
| [Changelog](https://github.com/COS301-SE-2026/Mealchemy/wiki/Changelog-Demo-3) | Version history and what changed each demo |

</details>


<details>
  <summary>Demo 2 - Click to expand</summary>

### Software Requirements Specifications (SRS)

| Page | Description |
|------|-------------|
| [Introduction](https://github.com/COS301-SE-2026/Mealchemy/wiki/SRS-Introduction-Demo-2) | Project background, motivation, and scope |
| [User Stories](https://github.com/COS301-SE-2026/Mealchemy/wiki/User-Stories-and-Characteristics-Demo-2) | Intended users and how they interact with the system |
| [Use Cases](https://github.com/COS301-SE-2026/Mealchemy/wiki/Use-Cases-Demo-2) | High-level use case diagrams and descriptions |
| [Functional Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Functional-Requirements-Demo-2) | Feature breakdown by subsystem |
| [Non-Functional Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Non‐Functional-Requirements-Demo-2) | Feature breakdown by subsystem |
| [Domain Model](https://github.com/COS301-SE-2026/Mealchemy/wiki/Domain-Model-Demo-2) | UML class diagram |

### Software Architecture Specifications (SAS)

| Page | Description |
|------|-------------|
| [Introduction](https://github.com/COS301-SE-2026/Mealchemy/wiki/SAS-Introduction-Demo-2) | Project background, motivation, and scope |
| [Architectural Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Architectural-Requirements-Demo-2) | Intended users and how they interact with the system |
| [Technology Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Technology-Requirements-Demo-2) | Technology Requirements |
| [API Service Contracts](https://github.com/COS301-SE-2026/Mealchemy/wiki/API-Service-Contracts-Demo-2) | API Contracts |
| [Deployment](https://github.com/COS301-SE-2026/Mealchemy/wiki/Deployment-Demo-2) | Deployment |

### Other Documents

| Page | Description |
|------|-------------|
| [Coding Standards Document](https://github.com/COS301-SE-2026/Mealchemy/wiki/Coding-Standards-Document-Demo-2) | Code style conventions and repository structure guidelines |
| [User Manual](https://github.com/COS301-SE-2026/Mealchemy/wiki/User-Manual-Document-Demo-2) | How to use the app - screenshots and feature walkthroughs |
| [Testing Policy Document](https://github.com/COS301-SE-2026/Mealchemy/wiki/Testing-Policy-Document-Demo-2) | Testing standards, types, tools, and responsibilities |
| [Changelog](https://github.com/COS301-SE-2026/Mealchemy/wiki/Changelog-Demo-2) | Version history and what changed each demo |

</details>

<details>
 <summary>Demo 1 - Click to expand</summary>

| Page | Description |
|------|-------------|
| [Introduction](https://github.com/COS301-SE-2026/Mealchemy/wiki/Introduction-Demo-1) | Project background, motivation, and scope |
| [User Stories](https://github.com/COS301-SE-2026/Mealchemy/wiki/User-Stories-User-Characteristics-Demo-1) | Intended users and how they interact with the system |
| [Use Cases](https://github.com/COS301-SE-2026/Mealchemy/wiki/Uses-Cases-Demo-1) | High-level use case diagrams and descriptions |
| [Functional Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Functional-Requirements-Demo-1) | Feature breakdown by subsystem |
| [API Service Contracts](https://github.com/COS301-SE-2026/Mealchemy/wiki/API-Service-Contracts-Demo-1) | API Contracts |
| [Domain Model](https://github.com/COS301-SE-2026/Mealchemy/wiki/Domain-model-Demo-1) | UML class diagram |
| [Quality Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Quality-Requirements-Demo-1) | Performance, security, scalability targets |
| [Architectural Patterns](https://github.com/COS301-SE-2026/Mealchemy/wiki/Architectural-Patterns-Demo-1) | Design and architectural pattern decisions |
| [Design Patterns](https://github.com/COS301-SE-2026/Mealchemy/wiki/Design-Patterns-Demo-1) | Design and architectural pattern decisions |
| [Architectural Constraints](https://github.com/COS301-SE-2026/Mealchemy/wiki/Architectural-Constraints-Demo-1) | Architectural Constraints |
| [Architectural Diagram](https://github.com/COS301-SE-2026/Mealchemy/wiki/Architectural-Diagram-Demo-1) | System architecture and component overview |
| [Technology Requirements](https://github.com/COS301-SE-2026/Mealchemy/wiki/Technology-Requirements-Demo-1) | Technology Requirements |

</details>

<br/>

</details>

## Getting started

**Prerequisites:** Docker Desktop · Java 21 · Flutter (stable) · Python 3.12

```bash
# Clone with the wiki submodule
git clone --recurse-submodules https://github.com/COS301-SE-2026/Mealchemy.git
cd Mealchemy

# Set up environment, then fill in your credentials in .env
cp .env.example .env

# Start Postgres and backend
docker compose -f infrastructure/docker-compose.yml --env-file .env up --build
```

Verify the backend is up:

```bash
curl http://localhost:8080/actuator/health
# -> {"status":"UP"}
```

<details>
<summary><b>Repository structure</b></summary>

<br/>

Mealchemy is a monorepo under the `COS301-SE-2026` organisation.

```
Mealchemy/
├── .github/
│   ├── workflows/             ← CI, CD, rollback, documentation, and delivery workflows
│   ├── codecov.yml            ← Codecov coverage thresholds and flags
│   └── labeler.yml            ← Pull-request auto-label rules
├── backend/                   ← Spring Boot Java 21 REST API
├── database/                  ← Versioned Flyway SQL migrations
├── design-spec/               ← Brand guide and wireframes deployed to GitHub Pages
├── diagrams/                  ← Architecture and deployment diagram files
├── docs/                      ← Local setup and deployment guides
├── e2e/                       ← Maestro end-to-end mobile tests
├── engine/                    ← Python 3.12 recommendation engine
├── frontend/                  ← Flutter mobile application
├── infrastructure/            ← Dockerfiles, Docker Compose, and cloud provisioning
├── landing-page/              ← Static landing page deployed to Firebase Hosting
├── nfr-tests/                 ← Executable non-functional test harness
│   ├── config/                ← Shared k6 environment and sanitized-summary helpers
│   ├── performance/           ← k6 load, resilience, and comparison tests
│   ├── results/               ← Sanitized NFR evidence files
│   └── security/              ← Authorization matrix and ZAP security tooling
├── wiki/                      ← Git submodule containing project documentation
├── .env.example               ← Template for local Docker configuration
├── .secrets.example           ← Template for local act CI secrets
├── firebase.json              ← Firebase Hosting deployment configuration
├── sonar-project.properties   ← SonarCloud analysis configuration
└── README.md
```

</details>

<details>
<summary><b>Branching strategy</b></summary>

<br/>

```text
main
 └── dev
      └── UseCase/{UseCase Name}
               └── feat/UC{n}-{description}/teamMember
```

| Branch | Purpose |
|:---|:---|
| `main` | Production-ready, always working. Protected, team lead merges only |
| `dev` | Integration branch, all completed work lands here first |
| `UseCase/{UseCase Name}` | One full use case end-to-end across backend, frontend and database |
| `feat/{UseCase}-{description}/TeamMember` | A sub-task within a use case, small and reviewable |
| `fix/{description}` | Bug fixes, merged into dev |
| `docs/{description}` | Documentation only, merged into dev |

</details>

<br/>

## Team

<div align="center">
  <img src="docs/photo_documentation/TeamPhoto.JPG" alt="Team PUL5E" width="640"/>
</div>

<br/>

<table>
  <tr>
    <td align="center" width="170" valign="middle">
      <img src="docs/photo_documentation/team/gabriela.png" width="130" alt="Gabriela Berimbau"/>
    </td>
    <td valign="middle">
      <b>Gabriela Berimbau</b> - Team Lead & Backend Developer<br/>
      <br/>
      <i>"Adaptable, organised and dependable: I lead with communication and build lasting connections."</i><br/>
      <sub>Theoretical computer science · Leadership</sub><br/>
      <br/>
      <a href="https://www.linkedin.com/in/gabriela-berimbau-b19866254">LinkedIn</a> · <a href="https://github.com/GabrielaBerimbau">GitHub</a> · <a href="mailto:giberimbau@gmail.com">Email</a>
    </td>
  </tr>
  <tr>
    <td align="center" width="170" valign="middle">
      <img src="docs/photo_documentation/team/megan.png" width="130" alt="Megan Azmanov"/>
    </td>
    <td valign="middle">
      <b>Megan Azmanov</b> - DevOps Lead & Full-Stack Developer<br/>
      <br/>
      <i>"A systems thinker who pairs analytical rigour with a creative edge."</i><br/>
      <sub>System integration · CI/CD · Containerisation</sub><br/>
      <br/>
      <a href="http://www.linkedin.com/in/megan-azmanov-409a983a8">LinkedIn</a> · <a href="https://github.com/Megan235">GitHub</a> · <a href="mailto:meganazmanov@gmail.com">Email</a>
    </td>
  </tr>
  <tr>
    <td align="center" width="170" valign="middle">
      <img src="docs/photo_documentation/team/sofia.png" width="130" alt="Sofia Finlayson"/>
    </td>
    <td valign="middle">
      <b>Sofia Finlayson</b> - Frontend Developer & Integration<br/>
      <br/>
      <i>"Detail-oriented and reliable, I make every component talk to the next seamlessly."</i><br/>
      <sub>Frontend &amp; backend · User-focused solutions</sub><br/>
      <br/>
      <a href="https://www.linkedin.com/in/sofia-finlayson-a751b61b4/">LinkedIn</a> · <a href="https://github.com/sofiafinlayson">GitHub</a> · <a href="mailto:finlaysonsofia@gmail.com">Email</a>
    </td>
  </tr>
  <tr>
    <td align="center" width="170" valign="middle">
      <img src="docs/photo_documentation/team/paul.png" width="130" alt="Paul Hofmeyr"/>
    </td>
    <td valign="middle">
      <b>Paul Hofmeyr</b> - Backend Developer & Recommendation Engine Architect<br/>
      <br/>
      <i>"Curious about how systems really work, from the fundamentals up."</i><br/>
      <sub>Cybersecurity · Self-directed learning</sub><br/>
      <br/>
      <a href="https://www.linkedin.com/in/paul-hofmeyr-a0b567308">LinkedIn</a> · <a href="https://github.com/PaulHofmeyr">GitHub</a> · <a href="mailto:psmhofmeyr@gmail.com">Email</a>
    </td>
  </tr>
  <tr>
    <td align="center" width="170" valign="middle">
      <img src="docs/photo_documentation/team/mutombo.png" width="130" alt="Mutombo Kabau"/>
    </td>
    <td valign="middle">
      <b>Mutombo Kabau</b> - Frontend Developer & Integration<br/>
      <br/>
      <i>"Driven to sharpen my craft, in the team and on personal projects."</i><br/>
      <sub>Frontend development · Frontend–backend integration</sub><br/>
      <br/>
      <a href="https://www.linkedin.com/in/mutombo-kabau-113091222">LinkedIn</a> · <a href="https://github.com/u24957102">GitHub</a> · <a href="mailto:kabau8605@gmail.com">Email</a>
    </td>
  </tr>
</table>

---

<div align="center">
  <sub>Built by <b>Team PUL5E</b> · COS301 Software Engineering · University of Pretoria · <a href="mailto:pulsefive@gmail.com">pulsefive@gmail.com</a></sub>
</div>
