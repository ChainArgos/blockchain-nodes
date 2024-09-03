#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull dogecoin-core
docker compose down dogecoin-core
docker compose up -d dogecoin-core
docker logs -f dogecoin-core
