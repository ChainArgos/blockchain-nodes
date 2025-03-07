#!/bin/bash
set -eou pipefail

exec geth \
  --datadir=/data/geth \
  --syncmode=full \
  --mainnet \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8649 \
  --txlookuplimit=0 \
  --txpool.nolocals
