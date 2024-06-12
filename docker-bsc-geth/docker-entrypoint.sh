#!/bin/bash
set -eou pipefail

if [ ! -d "/data/geth" ]; then
  echo "Init genesis with Hash-Base Storage Scheme by default."

  /usr/local/bin/geth --db.engine=pebble --datadir=/data init /genesis.json
fi

echo "Initialization completed successfully"

exec "$@"
