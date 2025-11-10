#!/bin/bash
set -euo pipefail

function bootstrap_script() {
  local DEFAULT_VOLUME="trivy_database"
  local VOLUME_NAME="${DOCKER_VOLUME_NAME:-$DEFAULT_VOLUME}"
  export USER_USED_TO_RUN_DOCKER="sudo docker"

  echo "⚙️ Initializing Docker environment..."

  # Check if docker command exists
  if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker is not installed or not in PATH."
    exit 1
  fi

  # Check if Docker daemon is reachable
  if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker daemon not responding. Make sure it's running."
    exit 1
  fi

  # Detect user privileges
  if groups "$USER" | grep -qw "docker"; then
    USER_USED_TO_RUN_DOCKER="docker"
  elif sudo -n docker info >/dev/null 2>&1; then
    USER_USED_TO_RUN_DOCKER="sudo docker"
  else
    echo "⚠️ Current user cannot access Docker daemon. Add user to 'docker' group or enable sudo access."
    exit 1
  fi
  export USER_USED_TO_RUN_DOCKER

  # Create Trivy volume if missing
  if ! docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
    echo "📦 Creating persistent volume: $VOLUME_NAME ..."
    $USER_USED_TO_RUN_DOCKER volume create "$VOLUME_NAME" >/dev/null
  else
    echo "✅ Volume $VOLUME_NAME already exists."
  fi

  # Optional: test by running lightweight container
  if ! $USER_USED_TO_RUN_DOCKER run --rm hello-world >/dev/null 2>&1; then
    echo "⚠️ Docker test container failed to run. Check daemon health."
  else
    echo "🚀 Docker is ready for analysis pipeline."
  fi
}

