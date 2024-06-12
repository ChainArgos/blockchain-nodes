#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

teku \
  --data-path=/data/teku \
  --ee-endpoint=http://ethereum-besu:8551 \
  --ee-jwt-secret-file=/data/jwtsecret.hex \
  --metrics-enabled=true \
  --checkpoint-sync-url=https://beaconstate.info
