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
  --blocks-reexecutor.mode=full \
  --chain.name=arb1 \
  --execution.rpc.log-history=0 \
  --execution.tx-indexer.tx-lookup-limit=0 \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --init.latest=pruned \
  --node.staker.enable=false \
  --parent-chain.blob-client.beacon-url="${CA_ETHEREUM_BEACON_URL}" \
  --parent-chain.blob-client.secondary-beacon-url="${CA_ETHEREUM_BEACON_ARCHIVER_URL}" \
  --parent-chain.connection.url="${CA_ETHEREUM_RPC_URL}" \
  --persistent.global-config=/data \
  --validation.wasm.allowed-wasm-module-roots=/workspace/nitro-legacy/machines,/workspace/target/machines
