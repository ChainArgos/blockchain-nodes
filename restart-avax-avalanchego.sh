#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull avax-avalanchego
docker compose down avax-avalanchego
docker compose up -d avax-avalanchego
docker logs -f avax-avalanchego
