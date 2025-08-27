#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

if [ ! -d "/data/heimdall" ]; then
  heimdalld init chainargos --home=/data/heimdall --chain-id heimdallv2-137

  # override with our config
  cp /config/app.toml /data/heimdall/config/app.toml
  cp /config/client.toml /data/heimdall/config/client.toml
  cp /config/config.toml /data/heimdall/config/config.toml

  # replace with mainnet genesis file
  cp /config/genesis.json.xz /data/heimdall/config/genesis.json.xz
  rm /data/heimdall/config/genesis.json
  unxz /data/heimdall/config/genesis.json.xz
fi

echo "Initialization completed successfully"

exec "$@"
