# Ladle
Ladle is a high performance tool for generating collaborative grocery lists.

## Purpose
This is a project I work on in my spare time for a few reasons:

1. To improve skills and demonstrate technical proficiency to potential employers across a broad range of subjects: System design, DevOps, Database administration, APIs, and front-end
2. To solve an actual problem I experience weekly
3. To have fun

## Problem
My partner and I make a grocery list once every week. We find this to be a time consuming task that is a bit annoying. It always takes us 30+ minutes to:

- Figure out what meals we will eat
- Determine what ingredients each meal requires
- Add them to a shopping cart (we typically order online on Walmart)
- Double check everything and make sure there's nothing else we want to add

During this process, there's lots of back and forth and collaboration is purely verbal communication. Once we pick up our groceries and begin to cook one of the meals, we typically look up the recipe again which is another point of friction.

## Solution
An app that allows us to build grocery lists quickly, asynchronously, and concurrently. There are two main phases during this process:

1. **Administration & configuration**: This phase typically includes listing meals that we might eat over a long period of time. Very little time is spent in this phase because it is usually something that after it's done once, we don't really have to think about it anymore. For instance, we might list 15 meals and their ingredients/recipes and over the next several months, choose 4-5 meals to eat from that same list each week.
2. **Selecting meals for the week**: This is the phase that causes the most toil. It is repetitive and must be done every week. It typically involves going through the the main list of meals that we've decided on during phase 1 and selecting 4-5 of them to cook for the given week. This also includes deciding on what drinks, snacks, and other items we want for that week.

Ladle will follow a similar workflow and support the following features that are broken down according to the phases described above:

### Administration & configuration
- Add ingredients
- Add meals
- Associate ingredients with meals
- Associate recipes with meals

### Selecting meals for the week
- Select meals for a grocery list with a single tap
- Support real time updates. When one user selects a meal, the other user immediately sees it
- Generate a list of ingredients with the click of a button

## How to run the app locally

### Prerequisites
- **Docker & Docker Compose** (v2+)
- **Go** (1.24+) if you want to run the server outside of Docker
- **Node.js** (18+) if you want to run the client outside of Docker
- **Environment file** at `infrastructure/docker/` — create a `.env` with:

```dotenv
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=ladle_db
# if running server without Docker, point at a local or remote Postgres:
DATABASE_URL=postgres://<USERNAME>:<PW>@localhost:5432/ladle_db?sslmode=disable
```

### Quick start with Docker Compose
Make sure you're running the Docker daemon and from the repo root you can run:

```bash
# build images and bring up all services
docker compose -f infrastructure/docker/compose.yaml up -d --build
```

- db → Postgres on localhost:5432
- server → Go API on localhost:8080
- client → SvelteKit on localhost:3000

To tear it down:

```bash
docker compose -f infrastructure/docker/compose.yaml down
```
**NOTE**: If you want to omit the `-f` flag, `cd infrastructure/docker` and run the commands without the flag.

## Directory structure
```bash
.
├── client/                 # SvelteKit frontend
├── server/                 # Go backend API
├── infrastructure
│   ├── cicd                # deploy scripts
│   ├── docker              # Docker config
│   └── terraform           # Terraform config
├── docs/                   # design & ops documentation
└── .github/                # CI/CD workflows
```
