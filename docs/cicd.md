# Ladle CI/CD Guide
This document explains how the CI/CD pipeline for the Ladle application is configured and runs.

## Table of Contents

- [Prerequisites](#prerequisites)
  - [Secrets](#secrets)
  - [DigitalOcean API Token](#digitalocean-api-token)
  - [DigitalOcean SSH Keys](#digitalocean-ssh-keys)
  - [Terraform Cloud API Token](#terraform-cloud-api-token)
- [Terraform Setup](#terraform-setup)
- [Docker Setup](#docker-setup)
- [GitHub Actions Workflows](#github-actions-workflows)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Secrets
The following repository secrets are required to run CI/CD wokflows/scripts.

- **SSH_PRIVATE_KEY**: Private key for the CI/CD SSH key pair, authorized on the DigitalOcean Droplet
- **TFC_TOKEN**: Terraform Cloud API token used to access the remote state
- **POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB**: Postgres credentials for Docker Compose at deploy time

### DigitalOcean API Token
A DigitalOcean API Token is required to run any Terraform plan/apply commands. This token is used by Terraform's DigitalOcean provider. The token can be stored as an environment variable with the key of `DIGITALOCEAN_TOKEN`. See the [provider reference for more information on this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs#token-1).

### DigitalOcean SSH Keys
SSH into a DigitalOcean Droplet by generating an SSH key pair and registering the public key on DigitalOcean. The following example demonstrates how this can be done for CI/CD.

- Generate a CI key pair: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/ladle_deploy_key -N ""`
- Add `ladle_deploy_key.pub` under DigitalOcean → Security → SSH Keys
- Add the private key as a secret in GitHub
- In Terraform, lookup by name and attach fingerprint/id to the Droplet’s ssh_keys

### Terraform Cloud API Token
Terraform Cloud API tokens can be used to access the HCP Terraform API and perform all the actions the associated user account is entitled to. For more information, see the [user API tokens documentation](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/users#tokens).

Treat these tokens like passwords, as they can be used to access your account without a username, password, or two-factor authentication.

This token is used to read/write the remote state.

#### Local
For local use, you can generate one with the `terraform login` command.

#### CI/CD
For CI/CD, you can follow these steps:

1. Create under Terraform Cloud → User Settings → Tokens
2. Store as `TFC_TOKEN` in GitHub Secrets
3. In workflows, set `TF_TOKEN_app_terraform_io` to that secret. For more information, see [how to configure credentials manually in the CLI configuration](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/users#tokens)

## Terraform Setup
Terraform Cloud is used to host the remote state. Any changes to infrastucture is currently done locally with the Terraform CLI. Before getting started, you will need a token to read/write the remote state. You can generate one with the `terraform login` command. See the [Terraform Cloud API Token](#terraform-cloud-api-token) section for more information.

As mentioned in the [Digital Ocean API Token section](#digitalocean-api-token), a `DIGITALOCEAN_TOKEN` environment variable is required for Terraform's DigitalOcean provider to work.

Once you have the required tokens setup, follow these steps to administer Terraform locally:

```bash
cd infrastructure/terraform/envs/dev
terraform init
terraform plan -out tfplan
terraform apply "tfplan"
```
If you need to attach a specific SSH key to the Droplet, you can run `terraform plan -var 'do_ssh_key_names=["key"]' -out tfplan`. The default keys attached are `macbook` and `cicd`. Additional SSH keys can be configured in the DigitalOcean app.

## Docker setup
The Ladle app is composed of three containers:

- **db**: PostgreSQL database
- **server**: Go backend API
- **client**: SvelteKit frontend

Locally, each image is built from its Dockerfile. Run them all via `docker compose up`. In CI/CD, images are built in a GitHub Actions workflow & pushed to GitHub Container Registry (GHCR), then on the Droplet a `compose.prod.override.yaml` is used to pull the published images instead of rebuilding.

## GitHub Actions Workflows

- **ci-tests.yml**: A reusable workflow to run client and server tests
- **test.yml**: Runs tests on PRs to main
- **deploy.yml**: Builds client/server images, publishes them to GHCR, reads Droplet IP from Terraform output, and SSH into Droplet to start containers.

## Troubleshooting

### Terraform auth failure
**Likely cause**: Expired or missing `DIGITALOCEAN_TOKEN/TFC_TOKEN`
**Potential solution**: Re-export the right token, verify it in GitHub Secrets, rerun terraform init.

### Docker build can’t find Dockerfile
**Likely cause**: Wrong `-f` path in CI or compose context
**Potential solution**: Confirm docker build `-f infrastructure/server.Dockerfile`. paths are correct.

### GHCR push unauthorized
**Likely cause**: GHCR_TOKEN lacks write:packages scope
**Potential solution**: Make sure `GITHUB_TOKEN` has permissions to push to GHCR. Typically, just make sure the workflow has the right permissions.

```yml
permissions:
  contents: read
  packages: write # allow pushing to GHCR
```

Alternatively, Regenerate PAT with proper scopes, update GitHub Secret, rerun workflow.

### SSH login fails in deploy step
**Likely cause**: Private key mismatch or wrong user/IP
**Potential solution**: Verify `SSH_PRIVATE_KEY` matches the public key on DO, check `$REMOTE_HOST IP`.

### App serves blank page
**Likely cause**: Wrong port mapping or missing build assets
**Potential solution**: Check `docker compose ps` ports, `docker exec` into container to list `/app/build`.
