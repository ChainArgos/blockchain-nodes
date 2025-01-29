#!/bin/bash
set -eou pipefail

exec geth \
  --syncmode=full \
  --datadir=/data/geth \
  --mainnet \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8649
