#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull kcc-geth
docker compose down kcc-geth
docker compose up -d kcc-geth
docker logs -f kcc-geth
