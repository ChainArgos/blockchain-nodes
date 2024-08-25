#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull cardano-node
docker compose down cardano-node
docker compose up -d cardano-node
docker logs -f cardano-node
