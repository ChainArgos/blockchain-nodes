#!/bin/bash
set -eou pipefail

export EL_PEERS=$(grep '^enode://' "/config/el-peers.txt"| tr '\n' ',' | sed 's/,$//')

exec reth \
  node \
  --authrpc.jwtsecret=/data/jwtsecret.hex \
  --chain=/config/eth-genesis.json \
  --datadir=/data/reth \
  --port=30303 \
  --http \
  --http.addr=0.0.0.0 \
  --http.port=8654 \
  --http.corsdomain="*" \
  --bootnodes="$EL_PEERS" \
  --trusted-peers="$EL_PEERS" \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.origins="*" \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=8551
