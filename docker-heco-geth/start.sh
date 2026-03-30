#!/bin/bash
set -eou pipefail

exec geth \
  --cache=8000 \
  --datadir=/data/geth \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.port=8646 \
  --http.vhosts=* \
  --maxpeers=200 \
  --syncmode=full \
  --txlookuplimit=0 \
  --txpool.nolocals
