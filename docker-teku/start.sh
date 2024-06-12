#!/bin/bash
set -eou pipefail

exec teku \
  --data-path=/data/teku \
  --ee-endpoint=http://ethereum-besu:8551 \
  --ee-jwt-secret-file=/data/jwtsecret.hex \
  --metrics-enabled=true \
  --checkpoint-sync-url=https://beaconstate.info
