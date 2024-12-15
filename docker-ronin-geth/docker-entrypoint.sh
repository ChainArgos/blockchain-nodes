#!/bin/bash
set -eou pipefail

echo "ChainArgos environment variables:"
env | grep CA_

if [ ! -d "/data/geth" ]; then
  echo "Init genesis."

  ronin init --datadir /data/geth /mainnet.json
fi

echo "Initialization completed successfully"

exec "$@"
