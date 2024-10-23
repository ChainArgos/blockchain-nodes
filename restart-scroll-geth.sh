#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull scroll-geth
docker compose down scroll-geth
docker compose up -d scroll-geth
docker logs -f scroll-geth
