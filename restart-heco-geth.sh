#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull heco-geth
docker compose down heco-geth
docker compose up -d heco-geth
docker logs -f heco-geth
