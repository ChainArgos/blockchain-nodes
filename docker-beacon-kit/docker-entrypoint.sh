#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

# initialize the data directory
ls -la /data > /dev/null

if [ ! -d "/data/beacon-kit" ]; then
  echo "Init data directory"

  beacond init chainargos --chain-id mainnet-beacon-80094 --home /data/beacon-kit
fi

if [ ! -f "/data/jwtsecret.hex" ]; then
  echo "Generating JWT secret"

  mkdir -pv /data
  beacond jwt generate -o /data/jwtsecret.hex

  echo ""
fi

echo "Initialization completed successfully"

exec "$@"
