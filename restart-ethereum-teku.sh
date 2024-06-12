#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull ethereum-teku
docker compose down ethereum-teku
docker compose up -d ethereum-teku
docker logs -f ethereum-teku
