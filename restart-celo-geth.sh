#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull celo-geth
docker compose down celo-geth
docker compose up -d celo-geth
docker logs -f celo-geth
