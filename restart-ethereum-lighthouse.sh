#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull ethereum-lighthouse
docker compose down ethereum-lighthouse
docker compose up -d ethereum-lighthouse
docker logs -f ethereum-lighthouse
