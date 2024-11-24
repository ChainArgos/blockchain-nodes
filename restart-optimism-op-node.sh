#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull optimism-op-node
docker compose down optimism-op-node
docker compose up -d optimism-op-node
docker logs -f optimism-op-node
