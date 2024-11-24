#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull optimism-op-geth
docker compose down optimism-op-geth
docker compose up -d optimism-op-geth
docker logs -f optimism-op-geth
