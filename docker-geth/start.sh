#!/bin/bash
set -eou pipefail

exec geth \
  --syncmode=full \
  --history.transactions=0 \
  --datadir=/data/geth \
  --db.engine=pebble \
  --mainnet \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --authrpc.jwtsecret=/data/jwtsecret.hex \
  --authrpc.addr=0.0.0.0 \
  --authrpc.vhosts=* \
  --authrpc.port=8551 \
  --maxpeers=200 \
  --cache=8000
