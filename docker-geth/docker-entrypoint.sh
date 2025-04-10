#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

# initialize the data directory
ls -la /data > /dev/null

if [[ -z "${CA_NETWORK}" ]]; then
  echo "ERROR: CA_NETWORK is not set"
  exit 1
fi

case $CA_NETWORK in

  berachain)
    if [ ! -d "/data/geth" ]; then
      echo "Init genesis geth."

      geth --db.engine=pebble --state.scheme=path --datadir=/data/geth init /config/berachain/genesis.json
    fi
    ;;

esac

if [ ! -f "/data/jwtsecret.hex" ]; then
  echo "Generating JWT secret"

  mkdir -pv /data
  openssl rand -hex 32 | tr -d "\n" > /data/jwtsecret.hex
fi

echo "Initialization completed successfully"

exec "$@"
