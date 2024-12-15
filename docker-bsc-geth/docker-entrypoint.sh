#!/bin/bash
set -eou pipefail

echo "ChainArgos environment variables:"
env | grep CA_

if [ ! -d "/data/geth" ]; then
  echo "Init genesis with Hash-Base Storage Scheme by default."

  geth --db.engine=pebble --datadir=/data/geth init /genesis.json
fi

echo "Initialization completed successfully"

exec "$@"
