#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull polygon-heimdall-rest-server
docker compose down polygon-heimdall-rest-server
docker compose up -d polygon-heimdall-rest-server
docker logs -f polygon-heimdall-rest-server
