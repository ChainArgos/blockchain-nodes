#!/bin/bash
set -e

if [[ -z "${ETHEREUM_EXECUTION_HOSTNAME}" ]]; then
  echo "ERROR: ETHEREUM_EXECUTION_HOSTNAME is not set"
  exit 1
fi

COMPONENT="${COMPONENT:-}"

case $COMPONENT in

  rest-server)
    exec heimdalld rest-server \
      --home=/data/heimdalld \
      --node "tcp://polygon-heimdall:26657"
    ;;

  *)
    exec heimdalld start \
      --chain=mainnet \
      --home=/data/heimdalld \
      --home-client=/data/heimdallcli \
      --eth_rpc_url=http://"${ETHEREUM_EXECUTION_HOSTNAME}":8545
    ;;

esac
