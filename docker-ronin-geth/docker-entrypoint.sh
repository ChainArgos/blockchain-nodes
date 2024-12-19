#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

if [ ! -d "/data/geth" ]; then
  echo "Init genesis."

  ronin init --datadir /data/geth /mainnet.json
fi

echo "Initialization completed successfully"

exec "$@"
