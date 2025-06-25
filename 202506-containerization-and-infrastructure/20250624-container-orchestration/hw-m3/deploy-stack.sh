#!/bin/bash

: "${EXPECTED_NODES}"

if [[ -z "$EXPECTED_NODES" ]]; then
  echo "[ERROR] EXPECTED_NODES is not set"
  exit 1
fi

: "${TIMEOUT:=360}"
: "${INTERVAL:=10}"

ATTEMPT=0

echo "[INFO] Waiting for $EXPECTED_NODES nodes to be Ready..."

while [ $ATTEMPT -lt $((TIMEOUT / INTERVAL)) ]; do
  READY_NODES=$(docker node ls --format '{{.Status}}' | grep -c Ready)

  if [ "$READY_NODES" -eq "$EXPECTED_NODES" ]; then
    echo "[INFO] All nodes are Ready! Proceeding with stack deployment..."
    exit 0
  fi

  echo "[INFO] $READY_NODES / $EXPECTED_NODES nodes Ready... retrying in $INTERVAL"
  sleep "$INTERVAL"
  ATTEMPT=$((ATTEMPT + 1))
done

echo "[ERROR] Timeout reached waiting for all nodes to be Ready."
exit 1
