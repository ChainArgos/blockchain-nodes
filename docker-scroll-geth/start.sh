#!/bin/bash
set -eou pipefail

if [[ -z "${ETHEREUM_EXECUTION_HOSTNAME}" ]]; then
  echo "ERROR: ETHEREUM_EXECUTION_HOSTNAME is not set"
  exit 1
fi

exec geth \
  --datadir=/data/geth \
  --scroll \
  --verbosity=3 \
  --syncmode=full \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8650 \
  --http.api=eth,net,web3,debug,scroll \
  --cache.noprefetch \
  --l1.endpoint=http://"${ETHEREUM_EXECUTION_HOSTNAME}":8545 \
  --rollup.verify
