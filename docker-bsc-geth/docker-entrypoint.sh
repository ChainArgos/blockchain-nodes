#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

if [ ! -d "/data/geth" ]; then
  echo "Init genesis geth."

  geth --db.engine=pebble --state.scheme=path --datadir=/data/geth init /config/genesis.json
fi

echo "Initialization completed successfully"

exec "$@"
