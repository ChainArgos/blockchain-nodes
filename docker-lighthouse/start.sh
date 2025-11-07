#!/bin/bash
set -eou pipefail

if [[ -z "${CA_ETHEREUM_EXECUTION_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_EXECUTION_URL is not set"
  exit 1
fi

# wait until local execution client comes up (authed so will return 401 without token)
until [ "$(curl -s -w '%{http_code}' -o /dev/null "${CA_ETHEREUM_EXECUTION_URL}")" -eq 401 ]; do
  echo "waiting for execution (geth) client to be ready"
  sleep 5
done

exec lighthouse \
  beacon_node \
  --datadir=/data/lighthouse \
  --checkpoint-sync-url=https://beaconstate.info \
  --execution-endpoint="${CA_ETHEREUM_EXECUTION_URL}" \
  --execution-jwt=/data/jwtsecret.hex \
  --network=mainnet \
  --genesis-backfill \
  --reconstruct-historic-states \
  --supernode \
  --http \
  --http-address=0.0.0.0
