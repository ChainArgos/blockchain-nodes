#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

docker compose pull tezos-octez
docker compose down tezos-octez
docker compose up -d tezos-octez
docker logs -f tezos-octez
