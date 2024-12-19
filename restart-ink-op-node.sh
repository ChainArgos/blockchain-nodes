#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull ink-op-node
docker compose down ink-op-node
docker compose up -d ink-op-node
docker logs -f ink-op-node
