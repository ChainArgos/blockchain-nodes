#!/bin/bash
set -eou pipefail

exec lighthouse \
  --datadir=/data/lighthouse \
  --network=mainnet \
  beacon_node \
  --execution-endpoint=http://ethereum-geth:8551 \
  --execution-jwt=/data/jwtsecret.hex \
  --checkpoint-sync-url=https://beaconstate.info
