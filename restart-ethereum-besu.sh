#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull ethereum-besu
docker compose down ethereum-besu
docker compose up -d ethereum-besu
docker logs -f ethereum-besu
