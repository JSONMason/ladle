#!/usr/bin/env bash
set -euo pipefail

REMOTE_USER="root"
REMOTE_APP_DIR="/opt/ladle-app"
REMOTE_DOCKER_DIR="${REMOTE_APP_DIR}/infrastructure/docker"
GIT_REPO="https://github.com/JSONMason/ladle.git"

ssh "${REMOTE_USER}@${REMOTE_HOST}" <<'EOF'
  set -euo pipefail

  # 1) Ensure base dir exists
  if [ ! -d "${REMOTE_APP_DIR}" ]; then
    mkdir -p "${REMOTE_APP_DIR}"
  fi

  # 2) Clone or update the repo
  if [ ! -d "${REMOTE_APP_DIR}/.git" ]; then
    echo "🔄 Cloning repository..."
    git clone "${GIT_REPO}" "${REMOTE_APP_DIR}"
  else
    echo "🔄 Pulling latest changes..."
    cd "${REMOTE_APP_DIR}"
    git fetch --all
    git reset --hard origin/main
  fi

  # 3) Go to the Docker Compose folder
  cd "${REMOTE_DOCKER_DIR}"

  # 4) Pull new images
  echo "📦 Pulling updated images..."
  docker compose pull
  docker compose -f compose.yaml -f compose.prod.override.yaml pull

  # 5) Recreate containers with zero downtime
  echo "🚀 Bringing up containers..."
  docker compose -f compose.yaml -f compose.prod.override.yaml up -d

  echo "✅ Deployment complete"
EOF
