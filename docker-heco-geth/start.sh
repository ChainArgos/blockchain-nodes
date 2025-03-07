#!/bin/bash
set -eou pipefail

exec geth \
  --syncmode=full \
  --datadir=/data/geth \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8646 \
  --maxpeers=200 \
  --cache=8000 \
  --txlookuplimit=0 \
  --txpool.nolocals
