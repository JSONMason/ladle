# CI/CD Guide for Ladle
This document explains how the CI/CD pipeline for the Ladle application is configured and runs. It covers:

- [Prerequisites (tokens, keys)](#prerequisites)
- Terraform Cloud setup
- DigitalOcean configuration
- Docker image build & registry
- GitHub Actions workflows
- deploy.sh script

## Table of Contents

- Prerequisites
- Terraform Cloud Configuration
- DigitalOcean Setup
- Docker & GHCR
- GitHub Actions Workflows
- deploy.sh script
- Usage
- Maintenance & Rotation
- Troubleshooting

## Prerequisites

### Secrets
The following repository secrets are required to run any CI/CD wokflows/scripts.

- **SSH_PRIVATE_KEY**: Private key for the CI/CD SSH key pair, authorized on the DigitalOcean Droplet
- **TFC_TOKEN**: Terraform Cloud API token for remote state
- **POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB**: Postgres credentials for Docker Compose at deploy time

### DigitalOcean API Token
A DigitalOcean API Token is required to run any Terraform plan/apply commands. This token is used by Terraform's DigitalOcean provider. The token can be stored as an environment variables with the key of `DIGITALOCEAN_TOKEN`. See the [provider reference for more information on this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs#token-1).

### DigitalOcean SSH Keys
SSH into a DigitalOcean Droplet by generating an SSH key pair and registering the public key on DigitalOcean. The following example demonstrates how this can be done for CI/CD.
- Generate a CI key pair: ssh-keygen -t rsa -b 4096 -f ~/.ssh/ladle_deploy_key -N ""
- Add ladle_deploy_key.pub under DigitalOcean → Security → SSH Keys
- Add the private key as a secret in GitHub
- In Terraform, lookup by name and attach fingerprint/id to the Droplet’s ssh_keys

### Terraform Cloud API Token (TFC_TOKEN)
• Create under Terraform Cloud → User Settings → Tokens
• Store as TFC_TOKEN in GitHub Secrets
• In workflows, set TF_TOKEN_app_terraform_io to that secret

Terraform Cloud Configuration
(in infrastructure/terraform/envs/dev)
terraform {
cloud {
organization = "Ladle"
workspaces { name = "ladle" }
}
}
provider "digitalocean" {}

variable "do_ssh_key_names" { type = list(string) }

data "digitalocean_ssh_key" "keys" {
for_each = toset(var.do_ssh_key_names)
name = each.value
}

module "ladle_vm" {
source = "../../modules/vm"
name = "ladle-app"
image = "docker-20-04"
region = "nyc3"
size = "s-1vcpu-1gb"
ssh_keys = [for k in data.digitalocean_ssh_key.keys : k.fingerprint]
}

output "droplet_ip" {
value = module.ladle_vm.droplet_ip
}

• Pass -var 'do_ssh_key_names=["macbook","cicd"]' or set a default
• Run terraform init && plan && apply locally

DigitalOcean Setup

API token stored as DIGITALOCEAN_TOKEN locally and in CI

SSH keys: macbook (your laptop) and cicd (GitHub Actions)

Terraform droplet resource attaches both via the ssh_keys list

Docker & GHCR
• Local dev: docker-compose.yml with build: directives
• Production override (compose.prod.override.yaml) replaces build with image:
services:
server: image: ghcr.io/jsonmason/ladle-server:latest
client: image: ghcr.io/jsonmason/ladle-client:latest
• CI pipelines build & push with docker/build-push-action@v6 for each service:
context: server
file: infrastructure/docker/server.Dockerfile
push: true
tags: ghcr.io/jsonmason/ladle-server:latest

GitHub Actions Workflows

Reusable CI Tests (.github/workflows/ci-tests.yml) – defines workflow_call job test-server

PR Tests (.github/workflows/test.yml) – on: pull_request → uses ci-tests.yml

CD Deploy (.github/workflows/deploy.yml)
permissions: contents: read, packages: write
on: push: main
jobs:
test: uses ci-tests.yml
deploy:
runs-on: ubuntu-latest
steps: checkout, buildx setup, registry login, build-push images, setup Terraform, terraform init, get droplet_ip, prepare SSH, run deploy.sh with POSTGRES_* envs

deploy.sh Script
Located at infrastructure/cicd/deploy.sh. Steps:

SSH into REMOTE_HOST as REMOTE_USER

mkdir -p REMOTE_APP_DIR

Clone or pull the repo into REMOTE_APP_DIR

Write .env under REMOTE_DOCKER_DIR with POSTGRES_USER, PASSWORD, DB via heredoc

cd REMOTE_DOCKER_DIR and run:
docker compose pull
docker compose -f compose.yaml -f compose.prod.override.yaml pull
docker compose -f compose.yaml -f compose.prod.override.yaml up -d

Usage
• Local infra: run Terraform locally
• Trigger CI: open/update PR → tests
• Trigger Deploy: merge to main → build, push images, SSH deploy

Maintenance & Rotation
• Rotate SSH keys (DigitalOcean and Terraform config)
• Rotate TFC_TOKEN in Terraform Cloud and GitHub Secrets
• Keep Action versions up to date

Troubleshooting
• 403 on GHCR → ensure packages: write permission in workflow
• Heredoc errors → confirm EOF delimiters are at column 0
• Missing .env → verify deploy.sh writes it after clone
• SSH auth failures → check public key on Droplet and SSH_PRIVATE_KEY secret

End of CI/CD Documentation






You said:
I’ve created comprehensive CI/CD documentation under **docs/ci-cd.md**, covering: * Folder layout * Required secrets and token management * Terraform Cloud and DigitalOcean setup * Docker builds & GHCR * GitHub Actions workflows * The deploy script * Usage, maintenance, and troubleshooting You can find it at `docs/ci-cd.md` in your repo. Let me know if you’d like any tweaks or additions!

please do this exact same thing again


ChatGPT said:
CI/CD Guide for Ladle
This document explains how the CI/CD pipeline for the Ladle application is configured and run. It covers:

Prerequisites (tokens, keys)

Terraform Cloud setup

DigitalOcean configuration

Docker image build & registry

GitHub Actions workflows

deploy.sh script behavior

Folder Structure Recommendation
Create a docs/ folder at the root of your repository. Inside, add:
/docs
└── ci-cd.md # This file

Table of Contents

Prerequisites

Terraform Cloud Configuration

DigitalOcean Setup

Docker & GHCR

GitHub Actions Workflows

deploy.sh Script

Usage

Maintenance & Rotation

Troubleshooting

Prerequisites
Before running any workflows or scripts, ensure the following secrets are stored in your GitHub repository under Settings → Secrets → Actions:
• DIGITALOCEAN_TOKEN: Your DigitalOcean API token for Terraform’s DO provider
• SSH_PRIVATE_KEY: Private key for the CI/CD SSH key pair, authorized on your Droplet
• TFC_TOKEN: Terraform Cloud API token for remote state and runs
• POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB: Postgres credentials for Docker Compose at deploy time

DigitalOcean API Token
• Create at DigitalOcean → API → Tokens (read/write for Droplet resources)

DigitalOcean SSH Keys
• Generate a CI key pair:
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ladle_deploy_key -N ""
• Add ladle_deploy_key.pub under DigitalOcean → Security → SSH Keys
• In Terraform, lookup by name or fingerprint and attach to your Droplet’s ssh_keys

Terraform Cloud API Token (TFC_TOKEN)
• Create under Terraform Cloud → User Settings → Tokens
• Store as TFC_TOKEN in GitHub Secrets
• In workflows, set TF_TOKEN_app_terraform_io to that secret

Terraform Cloud Configuration
(in infrastructure/terraform/envs/dev)

terraform {
cloud {
organization = "Ladle"
workspaces { name = "ladle" }
}
}
provider "digitalocean" {}

variable "do_ssh_key_names" { type = list(string) }

data "digitalocean_ssh_key" "keys" {
for_each = toset(var.do_ssh_key_names)
name = each.value
}

module "ladle_vm" {
source = "../../modules/vm"
name = "ladle-app"
image = "docker-20-04"
region = "nyc3"
size = "s-1vcpu-1gb"
ssh_keys = [for k in data.digitalocean_ssh_key.keys : k.fingerprint]
}

output "droplet_ip" {
value = module.ladle_vm.droplet_ip
}

• Pass -var 'do_ssh_key_names=["macbook","cicd"]' or set a default
• Run terraform init && plan && apply locally

DigitalOcean Setup

API token stored as DIGITALOCEAN_TOKEN locally and in CI

SSH keys: macbook (your laptop) and cicd (GitHub Actions)

Terraform droplet resource attaches both via the ssh_keys list

Docker & GHCR
• Local dev: docker-compose.yml with build: directives
• Production override (compose.prod.override.yaml) replaces build with image:
services:
server: image: ghcr.io/jsonmason/ladle-server:latest
client: image: ghcr.io/jsonmason/ladle-client:latest
• CI pipelines build & push with docker/build-push-action@v6 for each service:
context: server
file: infrastructure/docker/server.Dockerfile
push: true
tags: ghcr.io/jsonmason/ladle-server:latest

GitHub Actions Workflows

Reusable CI Tests (.github/workflows/ci-tests.yml) – defines workflow_call job test-server

PR Tests (.github/workflows/test.yml) – on: pull_request → uses ci-tests.yml

CD Deploy (.github/workflows/deploy.yml)
permissions: contents: read, packages: write
on: push: main
jobs:
test: uses ci-tests.yml
deploy:
runs-on: ubuntu-latest
steps: checkout, buildx setup, registry login, build-push images, setup Terraform, terraform init, get droplet_ip, prepare SSH, run deploy.sh with POSTGRES_* envs

deploy.sh Script
Located at infrastructure/cicd/deploy.sh. Steps:

SSH into REMOTE_HOST as REMOTE_USER

mkdir -p REMOTE_APP_DIR

Clone or pull the repo into REMOTE_APP_DIR

Write .env under REMOTE_DOCKER_DIR with POSTGRES_USER, PASSWORD, DB via heredoc

cd REMOTE_DOCKER_DIR and run:
docker compose pull
docker compose -f compose.yaml -f compose.prod.override.yaml pull
docker compose -f compose.yaml -f compose.prod.override.yaml up -d

Usage
• Local infra: run Terraform locally
• Trigger CI: open/update PR → tests
• Trigger Deploy: merge to main → build, push images, SSH deploy

Maintenance & Rotation
• Rotate SSH keys (DigitalOcean and Terraform config)
• Rotate TFC_TOKEN in Terraform Cloud and GitHub Secrets
• Keep Action versions up to date

Troubleshooting
• 403 on GHCR → ensure packages: write permission in workflow
• Heredoc errors → confirm EOF delimiters are at column 0
• Missing .env → verify deploy.sh writes it after clone
• SSH auth failures → check public key on Droplet and SSH_PRIVATE_KEY secret
