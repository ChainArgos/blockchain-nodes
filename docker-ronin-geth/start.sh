#!/bin/bash
set -eou pipefail

exec ronin \
  --networkid=2020 \
  --discovery.dns=enrtree://AIGOFYDZH6BGVVALVJLRPHSOYJ434MPFVVQFXJDXHW5ZYORPTGKUI@nodes.roninchain.com  \
  --syncmode=full \
  --datadir=/data/geth \
  --db.engine=pebble \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8745 \
  --http.api=eth,net,web3,consortium \
  --nodiscover
