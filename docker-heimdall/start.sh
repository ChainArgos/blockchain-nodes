#!/bin/bash
set -e

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
      --eth_rpc_url=http://162.55.65.74:8545
    ;;

esac
