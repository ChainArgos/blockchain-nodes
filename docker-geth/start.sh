#!/bin/bash
set -eou pipefail

exec geth \
  --syncmode=full \
  --datadir=/data/geth \
  --db.engine=pebble \
  --mainnet \
  --authrpc.jwtsecret=/data/jwtsecret.hex \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=8551 \
  --authrpc.vhosts=* \
  --maxpeers=200 \
  --cache=8000
