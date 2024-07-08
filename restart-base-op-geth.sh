#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull base-op-geth
docker compose down base-op-geth
docker compose up -d base-op-geth
docker logs -f base-op-geth
