#!/bin/bash
set -eou pipefail

if [[ -z "${CA_NETWORK}" ]]; then
  echo "ERROR: CA_NETWORK is not set"
  exit 1
fi

case $CA_NETWORK in
  ethereum)
    export ca_op_geth_hostname="ethereum-geth"
    ;;

  gnosis)
    export ca_op_geth_hostname="gnosis-geth"
    ;;

  *)
    echo "ERROR: CA_NETWORK is not correct, current value: ${CA_NETWORK}"
    exit 1
    ;;
esac

# wait until local execution client comes up (authed so will return 401 without token)
until [ "$(curl -s -w '%{http_code}' -o /dev/null "http://${ca_op_geth_hostname}:8551")" -eq 401 ]; do
  echo "waiting for execution (geth) client to be ready"
  sleep 5
done

case $CA_NETWORK in

  ethereum)
    exec lighthouse \
      beacon_node \
      --checkpoint-sync-url-timeout=300 \
      --checkpoint-sync-url=https://beaconstate.ethstaking.io \
      --datadir=/data/lighthouse \
      --execution-endpoint=http://"${ca_op_geth_hostname}":8551 \
      --execution-jwt=/data/jwtsecret.hex \
      --genesis-backfill \
      --http \
      --http-address=0.0.0.0 \
      --network=mainnet \
      --reconstruct-historic-states \
      --supernode
  ;;

  gnosis)
    exec lighthouse \
      beacon_node \
      --checkpoint-sync-url-timeout=300 \
      --checkpoint-sync-url=https://checkpoint.gnosischain.com \
      --datadir=/data/lighthouse \
      --execution-endpoint=http://"${ca_op_geth_hostname}":8551 \
      --execution-jwt=/data/jwtsecret.hex \
      --http \
      --http-address=0.0.0.0 \
      --http-port=4000 \
      --network=gnosis \
      --port=9000
      ;;

    *)
      echo "ERROR: CA_NETWORK is not correct, current value: ${CA_NETWORK}"
      exit 1
      ;;

  esac
