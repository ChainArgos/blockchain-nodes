#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

if [ ! -d "/data/geth" ]; then
  echo "Init genesis with Hash-Base Storage Scheme by default."

  geth --db.engine=pebble --datadir=/data/geth init /genesis.json
fi

echo "Initialization completed successfully"

exec "$@"
