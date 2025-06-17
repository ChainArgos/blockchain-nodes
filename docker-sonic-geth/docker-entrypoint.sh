#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

if [ ! -d "/data/geth" ]; then
  echo "Init genesis."

  sonictool --datadir /data/geth genesis /config/sonic.g
fi

echo "Initialization completed successfully"

exec "$@"
