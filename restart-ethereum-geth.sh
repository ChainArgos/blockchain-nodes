#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull ethereum-geth
docker compose down ethereum-geth
docker compose up -d ethereum-geth
docker logs -f ethereum-geth
