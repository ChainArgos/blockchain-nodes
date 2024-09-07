#!/bin/bash
set -eou pipefail

exec ronin \
  --networkid=2020 \
  --discovery.dns=enrtree://AIGOFYDZH6BGVVALVJLRPHSOYJ434MPFVVQFXJDXHW5ZYORPTGKUI@nodes.roninchain.com \
  --finality.enable \
  --txpool.globalqueue=10000 \
  --txpool.globalslots=10000 \
  --verbosity=3 \
  --syncmode=full \
  --datadir=/data/geth \
  --http \
  --http.api eth,net,web3,consortium \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8745 \
  --maxpeers=200 \
  --cache=8000 \
  --allow-insecure-unlock
