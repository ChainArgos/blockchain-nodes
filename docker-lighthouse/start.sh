#!/bin/bash
set -eou pipefail

# wait until local execution client comes up (authed so will return 401 without token)
until [ "$(curl -s -w '%{http_code}' -o /dev/null "http://ethereum-geth:8551")" -eq 401 ]; do
  echo "waiting for execution (geth) client to be ready"
  sleep 5
done

exec lighthouse \
  --datadir=/data/lighthouse \
  --network=mainnet \
  beacon_node \
  --execution-endpoint=http://ethereum-geth:8551 \
  --execution-jwt=/data/jwtsecret.hex \
  --checkpoint-sync-url=https://beaconstate.info \
  --http \
  --http-address=0.0.0.0 \
  --prune-blobs=false \
  --genesis-backfill \
  --reconstruct-historic-states
