#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

if [ ! -d "/data/heimdall" ]; then
  heimdalld init chainargos --chain=mainnet --home=/data/heimdall

  # override with our config
  cp /config/config.toml /data/heimdall/config/config.toml

  # replace with mainnet genesis file
  cp /config/genesis.json /data/heimdall/config/genesis.json

  cp /config/heimdall-config.toml /data/heimdall/config/heimdall-config.toml
fi

echo "Initialization completed successfully"

exec "$@"
