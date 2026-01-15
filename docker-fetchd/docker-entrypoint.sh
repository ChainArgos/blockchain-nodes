#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

if [ ! -d "/data/fetchd" ]; then
  fetchd init chainargos --chain-id fetchhub-4 --home=/data/fetchd

  # replace with mainnet genesis file
  rm /data/fetchd/config/genesis.json
  cp /config/genesis.json.xz /data/fetchd/config/genesis.json.xz
  unxz /data/fetchd/config/genesis.json.xz

  chmod 600 /data/fetchd/config/priv_validator_key.json
fi

echo "Initialization completed successfully"

exec "$@"
