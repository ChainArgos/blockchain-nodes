#!/bin/bash
set -eou pipefail

if [[ -z "${CA_ETHEREUM_RPC_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_RPC_URL is not set"
  exit 1
fi

if [[ -z "${CA_ETHEREUM_BEACON_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_BEACON_URL is not set"
  exit 1
fi

exec nitro \
  --parent-chain.connection.url="${CA_ETHEREUM_RPC_URL}" \
  --parent-chain.blob-client.beacon-url="${CA_ETHEREUM_BEACON_URL}" \
  --chain.name=arb1 \
  --init.empty \
  --blocks-reexecutor.mode=full \
  --persistent.global-config=/data \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --execution.caching.archive \
  --execution.tx-lookup-limit=0
