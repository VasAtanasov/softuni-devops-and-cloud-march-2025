#!/bin/bash

set -euo pipefail

: "${EXPECTED_NODES:?EXPECTED_NODES is not set}"
: "${STACK_NAME:?STACK_NAME is not set}"
: "${TIMEOUT:=360}"
: "${INTERVAL:=10}"
: "${DOCKER_COMPOSE_FILE:=docker-compose.yaml}"
: "${DOCKER_COMPOSE_ENV_FILE:=}"

check_prerequisites() {
  for cmd in docker yq sed awk; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "[ERROR] '$cmd' command not found. Please install it first."
      exit 1
    fi
  done

  if [[ ! -f "$DOCKER_COMPOSE_FILE" ]]; then
    echo "[ERROR] Docker Compose file '$DOCKER_COMPOSE_FILE' not found."
    exit 1
  fi

  if [[ -n "$DOCKER_COMPOSE_ENV_FILE" && ! -f "$DOCKER_COMPOSE_ENV_FILE" ]]; then
    echo "[ERROR] Env file '$DOCKER_COMPOSE_ENV_FILE' is set but does not exist."
    exit 1
  fi

  if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -qE 'active|pending'; then
    echo "[ERROR] This node is not part of an active Docker Swarm."
    exit 1
  fi
}

count_ready_nodes() {
  docker node ls --format '{{.ID}} {{.Status}} {{.Availability}}' \
    | awk '$2 == "Ready" && $3 == "Active"' \
    | wc -l
}

deploy_stack() {
  compose_args=(-f "$DOCKER_COMPOSE_FILE")
  [[ -n "$DOCKER_COMPOSE_ENV_FILE" ]] && compose_args+=( --env-file "$DOCKER_COMPOSE_ENV_FILE")

  docker compose "${compose_args[@]}" config
  docker compose "${compose_args[@]}" build
  docker compose "${compose_args[@]}" push
  docker compose "${compose_args[@]}" pull

  docker compose "${compose_args[@]}" config \
    | sed -E '/published:/s/"//g;/^name:/d' \
    | yq 'del(.services[].depends_on) | del(.services[].build)' -y \
    | docker stack deploy -c - "$STACK_NAME"
}

check_prerequisites

ATTEMPT=0
MAX_ATTEMPTS=$((TIMEOUT / INTERVAL))

echo "[INFO] Waiting for $EXPECTED_NODES nodes to be Ready..."

while [ "$ATTEMPT" -lt "$MAX_ATTEMPTS" ]; do
  READY_NODES=$(count_ready_nodes)

  if [ "$READY_NODES" -eq "$EXPECTED_NODES" ]; then
    echo "[INFO] All $READY_NODES nodes are Ready! Proceeding with stack deployment..."
    deploy_stack
    exit 0
  fi

  echo "[INFO] $READY_NODES / $EXPECTED_NODES nodes Ready... retrying in $INTERVAL"
  sleep "$INTERVAL"
  ATTEMPT=$((ATTEMPT + 1))
done

echo "[ERROR] Timeout reached waiting for all nodes to be Ready."
exit 1
