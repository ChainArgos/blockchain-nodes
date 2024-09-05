#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull ronin-geth
docker compose down ronin-geth
docker compose up -d ronin-geth
docker logs -f ronin-geth
