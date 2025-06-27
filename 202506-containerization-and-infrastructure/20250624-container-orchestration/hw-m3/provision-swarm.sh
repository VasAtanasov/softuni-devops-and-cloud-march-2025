#!/usr/bin/env bash
set -euo pipefail

echo "* Setting up Docker tools and services..."

echo "source <(docker completion bash)" >> /home/vagrant/.bashrc

if ! docker service ls | grep -q visualizer; then
  echo "* Starting Visualizer Service..."
  docker service create \
    --detach=true \
    --name=visualizer \
    --publish=8001:8080 \
    --constraint=node.role==manager \
    --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --mode replicated \
    --replicas=1 \
    dockersamples/visualizer
fi

if ! docker service ls | grep -q registry; then
  echo "* Starting Local Docker Registry Service..."
  docker service create \
    --detach=true \
    --name registry \
    --publish published=5000,target=5000 \
    --constraint=node.role==manager \
    --mode replicated \
    --mount type=bind,src=/mnt/registry,dst=/var/lib/registry \
    --replicas=1 \
    registry:2
fi

if ! docker stack ls | grep -q portainer; then
  echo "* Deploying Portainer Stack For Docker Swarm..."
  docker stack deploy -c /vagrant/portainer-agent-stack.yml portainer
fi

echo "Shared Docker services provisioned."
