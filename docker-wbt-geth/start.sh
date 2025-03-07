#!/bin/bash
set -eou pipefail

exec geth \
  --datadir=/data/geth \
  --syncmode=full \
  --db.engine=pebble \
  --wbt-mainnet \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8653 \
  --authrpc.jwtsecret=/data/jwtsecret.hex \
  --authrpc.addr=0.0.0.0 \
  --authrpc.vhosts=* \
  --authrpc.port=8551 \
  --txlookuplimit=0 \
  --txpool.nolocals=true
