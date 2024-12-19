#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eou pipefail

if [[ -z "${CA_NETWORK}" ]]; then
  echo "ERROR: CA_NETWORK is not set"
  exit 1
fi

# initialize the data directory
ls -la /data > /dev/null

if [ ! -f "/data/jwtsecret.hex" ]; then
  echo "Generating JWT secret"

  mkdir -pv /data
  openssl rand -hex 32 | tr -d "\n" > /data/jwtsecret.hex
fi

case $CA_NETWORK in
  ink)
    if [ ! -d "/data/op-geth" ]; then
      echo "Init genesis with Hash-Base Storage Scheme by default."

      geth --state.scheme=hash --db.engine=pebble --datadir=/data/op-geth init /ink/genesis.json
    fi
    ;;
esac

echo "Initialization completed successfully"

exec "$@"
