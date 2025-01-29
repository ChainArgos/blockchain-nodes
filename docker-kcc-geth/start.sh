#!/bin/bash
set -eou pipefail

exec geth \
  --syncmode=full \
  --datadir=/data/geth \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8647 \
  --maxpeers=200 \
  --cache=8000
