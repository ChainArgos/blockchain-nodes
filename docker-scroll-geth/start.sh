#!/bin/bash
set -eou pipefail

if [[ -z "${CA_ETHEREUM_RPC_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_RPC_URL is not set"
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
  --l1.endpoint="${CA_ETHEREUM_RPC_URL}" \
  --rollup.verify
