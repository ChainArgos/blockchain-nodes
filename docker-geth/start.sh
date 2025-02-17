#!/bin/bash
set -eou pipefail

exec geth \
  --datadir=/data/geth \
  --db.engine=pebble \
  --history.transactions=0 \
  --state.scheme=path \
  --syncmode=snap \
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
