#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

if [ ! -d "/data/heimdall" ]; then
  heimdalld init --chain=mainnet --home=/data/heimdall --home-client=/data/heimdallcli

  # override with our config
  cp /config.toml /data/heimdall/config/config.toml

  # replace with mainnet genesis file
  cp /genesis.json /data/heimdall/config/genesis.json

  cp /heimdall-config.toml /data/heimdall/config/heimdall-config.toml
fi

echo "Initialization completed successfully"

exec "$@"
