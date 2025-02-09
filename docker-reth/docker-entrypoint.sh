#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

# initialize the data directory
ls -la /data > /dev/null

if [ ! -d "/data/reth" ]; then
  echo "Init data directory"

  reth init --chain /config/eth-genesis.json --datadir /data/reth
fi

echo "Initialization completed successfully"

exec "$@"
