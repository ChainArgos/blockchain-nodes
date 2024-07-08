#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull base-op-node
docker compose down base-op-node
docker compose up -d base-op-node
docker logs -f base-op-node
