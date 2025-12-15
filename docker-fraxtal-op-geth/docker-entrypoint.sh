#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

# initialize the data directory
ls -la /data > /dev/null

if [ ! -f "/data/jwtsecret.hex" ]; then
  echo "Generating JWT secret"

  mkdir -pv /data
  openssl rand -hex 32 | tr -d "\n" > /data/jwtsecret.hex
fi

if [ ! -d "/data/op-geth" ]; then
  echo "Init genesis op-geth."

  geth --db.engine=pebble --state.scheme=path --datadir=/data/op-geth init /config/genesis.json
fi

echo "Initialization completed successfully"

exec "$@"
