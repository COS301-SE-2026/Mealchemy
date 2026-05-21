# Render Setup

## What is Render

Render is a cloud hosting platform that deploys and runs web services directly from a GitHub repository. When code is pushed to a branch, Render can automatically pull the latest version, build it, and redeploy the service without any manual steps.

For Mealchemy, Render hosts the Spring Boot backend so it is accessible over the internet rather than just on a local machine. This is what makes the app usable on a real devices without needing Docker running on your laptop.

## How it works

Render connects to the GitHub repository and watches a specific branch ( `main`). When a new commit lands on that branch, Render triggers a new deployment automatically. It pulls the code, runs the build command, and starts the service. If the build fails, the previous deployment stays live.

Each service on Render gets a public URL that the Flutter app uses as its backend base URL.

## What we use Render for

Render hosts the Mealchemy backend as a live endpoint so that Uptime Robot has a URL
to ping for uptime monitoring. This is what powers the uptime monitoring badge on the
README.

The live backend URL is:

https://mealchemy-backend.onrender.com

Uptime Robot pings the health endpoint at regular intervals:

https://mealchemy-backend.onrender.com/actuator/health

Expected response:

```json
{ "status": "UP" }
```

## Free tier behaviour

Render's free tier spins down the service after 15 minutes of inactivity. The first ping
after a spin-down takes 30 to 60 seconds to respond while the service boots back up.

