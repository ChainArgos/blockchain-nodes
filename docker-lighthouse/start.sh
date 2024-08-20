#!/bin/bash
set -eou pipefail

if [[ -z "${ETHEREUM_EXECUTION_HOSTNAME}" ]]; then
  echo "ERROR: ETHEREUM_EXECUTION_HOSTNAME is not set"
  exit 1
fi

exec lighthouse \
  --datadir=/data/lighthouse \
  --network=mainnet \
  beacon_node \
  --execution-endpoint=http://"${ETHEREUM_EXECUTION_HOSTNAME}":8551 \
  --execution-jwt=/data/jwtsecret.hex \
  --checkpoint-sync-url=https://beaconstate.info \
  --http \
  --http-address=0.0.0.0 \
  --prune-blobs=false
