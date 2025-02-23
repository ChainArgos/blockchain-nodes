#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

if [ ! -d "/data/geth" ]; then
  echo "Init genesis geth."

  ronin --db.engine=pebble --state.scheme=path --datadir=/data/geth init /config/mainnet.json
fi

echo "Initialization completed successfully"

exec "$@"
