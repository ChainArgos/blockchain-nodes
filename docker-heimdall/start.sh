#!/bin/bash
set -e

if [[ -z "${CA_ETHEREUM_RPC_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_RPC_URL is not set"
  exit 1
fi

COMPONENT="${COMPONENT:-}"

case $COMPONENT in

  rest-server)
    exec heimdalld rest-server \
      --home=/data/heimdall \
      --node "tcp://polygon-heimdall:26657"
    ;;

  *)
    exec heimdalld start \
      --chain=mainnet \
      --home=/data/heimdall \
      --home-client=/data/heimdallcli \
      --rest-server
    ;;

esac
