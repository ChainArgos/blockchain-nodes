#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

if [ ! -d "/data/geth" ]; then
  echo "Init genesis."

  ronin init --datadir /data/geth /mainnet.json
fi

echo "Initialization completed successfully"

exec "$@"
