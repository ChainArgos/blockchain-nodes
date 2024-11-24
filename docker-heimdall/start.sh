#!/bin/bash
set -e

if [[ -z "${POLYGON_HEIMDALL_HOSTNAME}" ]]; then
  echo "ERROR: POLYGON_HEIMDALL_HOSTNAME is not set"
  exit 1
fi

if [[ -z "${CA_ETHEREUM_RPC_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_RPC_URL is not set"
  exit 1
fi

COMPONENT="${COMPONENT:-}"

case $COMPONENT in

  rest-server)
    exec heimdalld rest-server \
      --home=/data/heimdalld \
      --node "tcp://${POLYGON_HEIMDALL_HOSTNAME}:26657"
    ;;

  *)
    exec heimdalld start \
      --chain=mainnet \
      --home=/data/heimdalld \
      --home-client=/data/heimdallcli \
      --bor_rpc_url=http://polygon-bor:8945 \
      --eth_rpc_url="${CA_ETHEREUM_RPC_URL}"
    ;;

esac
