#!/bin/bash
set -eou pipefail

exec geth \
  --syncmode=full \
  --datadir=/data/geth \
  --db.engine=pebble \
  --wbt-mainnet \
  --authrpc.jwtsecret=/data/jwtsecret.hex \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8653 \
  --authrpc.addr=0.0.0.0 \
  --authrpc.vhosts=* \
  --authrpc.port=8551