#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull polygon-bor
docker compose down polygon-bor
docker compose up -d polygon-bor
docker logs -f polygon-bor
