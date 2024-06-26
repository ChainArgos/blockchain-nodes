#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull bsc-geth
docker compose down bsc-geth
docker compose up -d bsc-geth
docker logs -f bsc-geth
