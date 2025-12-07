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
      --datadir=/data/lighthouse \
      --checkpoint-sync-url=https://mainnet.checkpoint.sigp.io \
      --checkpoint-sync-url-timeout=300 \
      --execution-endpoint=http://"${ca_op_geth_hostname}":8551 \
      --execution-jwt=/data/jwtsecret.hex \
      --network=mainnet \
      --genesis-backfill \
      --reconstruct-historic-states \
      --supernode \
      --http \
      --http-address=0.0.0.0
  ;;

  gnosis)
    exec lighthouse \
      beacon_node \
      --datadir=/data/lighthouse \
      --checkpoint-sync-url=https://checkpoint.gnosischain.com \
      --checkpoint-sync-url-timeout=300 \
      --execution-endpoint=http://"${ca_op_geth_hostname}":8551 \
      --execution-jwt=/data/jwtsecret.hex \
      --network=gnosis \
      --port=9000 \
      --http \
      --http-address=0.0.0.0 \
      --http-port=4000
      ;;

    *)
      echo "ERROR: CA_NETWORK is not correct, current value: ${CA_NETWORK}"
      exit 1
      ;;

  esac
