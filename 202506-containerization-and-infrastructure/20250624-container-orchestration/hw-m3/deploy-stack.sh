#!/bin/bash

: "${EXPECTED_NODES}"

if [[ -z "$EXPECTED_NODES" ]]; then
  echo "[ERROR] EXPECTED_NODES is not set"
  exit 1
fi

: "${TIMEOUT:=360}"
: "${INTERVAL:=10}"
: "${DOCKER_COMPOSE_FILE:=docker-compose.yaml}"
: "${DOCKER_COMPOSE_ENV_FILE:=.env}"
: "${STACK_NAME}"

if [[ -z "$STACK_NAME" ]]; then
  echo "[ERROR] STACK_NAME is not set"
  exit 1
fi

ATTEMPT=0

echo "[INFO] Waiting for $EXPECTED_NODES nodes to be Ready..."

while [ $ATTEMPT -lt $((TIMEOUT / INTERVAL)) ]; do
  READY_NODES=$(docker node ls --format '{{.Status}}' | grep -c Ready)

  if [ "$READY_NODES" -eq "$EXPECTED_NODES" ]; then
    echo "[INFO] All nodes are Ready! Proceeding with stack deployment..."
    docker compose -f "${DOCKER_COMPOSE_FILE}" --env-file "${DOCKER_COMPOSE_ENV_FILE}" config
    docker compose -f "${DOCKER_COMPOSE_FILE}" --env-file "${DOCKER_COMPOSE_ENV_FILE}" build && \
    docker compose -f "${DOCKER_COMPOSE_FILE}" --env-file "${DOCKER_COMPOSE_ENV_FILE}" push
    docker compose -f "${DOCKER_COMPOSE_FILE}" --env-file "${DOCKER_COMPOSE_ENV_FILE}" pull && \
    docker compose -f "${DOCKER_COMPOSE_FILE}" config \
      | sed -E '/published:/s/"//g;/^name:/d' \
      | yq 'del(.services[].depends_on) | del(.services[].build)' -y \
      | docker stack deploy -c - "${STACK_NAME}"
    exit 0
  fi

  echo "[INFO] $READY_NODES / $EXPECTED_NODES nodes Ready... retrying in $INTERVAL"
  sleep "$INTERVAL"
  ATTEMPT=$((ATTEMPT + 1))
done

echo "[ERROR] Timeout reached waiting for all nodes to be Ready."
exit 1
