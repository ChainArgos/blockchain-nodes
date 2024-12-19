#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull ink-op-geth
docker compose down ink-op-geth
docker compose up -d ink-op-geth
docker logs -f ink-op-geth
