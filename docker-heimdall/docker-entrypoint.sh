#!/bin/bash
set -eou pipefail

echo "ChainArgos environment variables:"
env | grep CA_

if [ ! -d "/data/heimdalld" ]; then
  heimdalld init --chain=mainnet --home=/data/heimdalld --home-client=/data/heimdallcli

  # override with our config
  cp /config.toml.sample /data/heimdalld/config/config.toml

  # replace with mainnet genesis file
  cp /genesis.json /data/heimdalld/config/genesis.json

  cp /heimdall-config.toml /data/heimdalld/config/heimdall-config.toml

  moniker=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12; echo)

  sed -i -e "s/NODE_NAME/$moniker/g" /data/heimdalld/config/config.toml
fi

echo "Initialization completed successfully"

exec "$@"
