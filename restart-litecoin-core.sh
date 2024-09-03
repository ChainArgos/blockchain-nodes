#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull litecoin-core
docker compose down litecoin-core
docker compose up -d litecoin-core
docker logs -f litecoin-core
