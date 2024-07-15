#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull polygon-heimdall
docker compose down polygon-heimdall
docker compose up -d polygon-heimdall
docker logs -f polygon-heimdall
