#!/bin/bash
set -eou pipefail

if [[ -z "${CA_ETHEREUM_RPC_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_RPC_URL is not set"
  exit 1
fi

# wait until local execution client comes up (authed so will return 401 without token)
until [ "$(curl -s -w '%{http_code}' -o /dev/null "${CA_ETHEREUM_RPC_URL}")" -eq 200 ]; do
  echo "waiting for execution (geth) client to be ready"
  sleep 5
done

exec geth \
  --datadir=/data/geth \
  --scroll \
  --verbosity=3 \
  --syncmode=full \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8650 \
  --http.api=eth,net,web3,debug,scroll \
  --cache.noprefetch \
  --l1.endpoint="${CA_ETHEREUM_RPC_URL}" \
  --rollup.verify
