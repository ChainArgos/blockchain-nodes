#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

if [ ! -d "/data/heimdall" ]; then
  heimdalld init --chain=mainnet --home=/data/heimdall --home-client=/data/heimdallcli

  # override with our config
  cp /config.toml.sample /data/heimdall/config/config.toml

  # replace with mainnet genesis file
  cp /genesis.json /data/heimdall/config/genesis.json

  cp /heimdall-config.toml /data/heimdall/config/heimdall-config.toml

  moniker=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12; echo)

  sed -i -e "s/NODE_NAME/$moniker/g" /data/heimdall/config/config.toml
fi

echo "Initialization completed successfully"

exec "$@"
