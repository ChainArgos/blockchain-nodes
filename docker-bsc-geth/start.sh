#!/bin/bash
set -eou pipefail

exec geth \
  --syncmode=full \
  --history.transactions=0 \
  --datadir=/data/geth \
  --db.engine=pebble \
  --mainnet \
  --config=/config.toml \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8645 \
  --maxpeers=200 \
  --cache=8000 \
  --nodiscover
