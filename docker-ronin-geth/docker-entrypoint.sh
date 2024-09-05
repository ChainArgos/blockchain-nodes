#!/bin/bash
set -eou pipefail

if [ ! -d "/data/geth" ]; then
  echo "Init genesis."

  ronin init --datadir /data/geth /mainnet.json
fi

echo "Initialization completed successfully"

exec "$@"
