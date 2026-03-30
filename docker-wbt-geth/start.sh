#!/bin/bash
set -eou pipefail

exec geth \
  --authrpc.addr=0.0.0.0 \
  --authrpc.jwtsecret=/data/jwtsecret.hex \
  --authrpc.port=8551 \
  --authrpc.vhosts=* \
  --cache=4096 \
  --datadir=/data/geth \
  --db.engine=pebble \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.port=8653 \
  --http.vhosts=* \
  --syncmode=full \
  --txlookuplimit=0 \
  --txpool.nolocals=true \
  --wbt-mainnet
