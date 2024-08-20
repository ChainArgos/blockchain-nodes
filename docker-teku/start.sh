#!/bin/bash
set -eou pipefail

if [[ -z "${ETHEREUM_EXECUTION_HOSTNAME}" ]]; then
  echo "ERROR: ETHEREUM_EXECUTION_HOSTNAME is not set"
  exit 1
fi

exec teku \
  --data-path=/data/teku \
  --ee-endpoint=http://"${ETHEREUM_EXECUTION_HOSTNAME}":8551 \
  --ee-jwt-secret-file=/data/jwtsecret.hex \
  --metrics-enabled=true \
  --checkpoint-sync-url=https://beaconstate.info
