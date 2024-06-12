#!/bin/bash
set -eou pipefail

exec besu \
  --sync-mode=FULL \
  --max-peers=200 \
  --p2p-peer-upper-bound=200 \
  --data-path=/data/besu \
  --data-storage-format=FOREST \
  --rpc-http-enabled=true \
  --rpc-http-host="0.0.0.0" \
  --rpc-ws-enabled=true \
  --rpc-ws-host="0.0.0.0" \
  --host-allowlist=all \
  --engine-host-allowlist=all \
  --engine-rpc-enabled \
  --engine-jwt-secret=/data/jwtsecret.hex
