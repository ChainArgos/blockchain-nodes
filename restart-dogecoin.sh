#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull dogecoin
docker compose down dogecoin
docker compose up -d dogecoin
docker logs -f dogecoin
