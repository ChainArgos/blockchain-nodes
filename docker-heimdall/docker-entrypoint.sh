#!/bin/bash
set -eou pipefail

if [ ! -d "/data/heimdalld" ]; then
  heimdalld init --chain=mainnet --home=/data/heimdalld --home-client=/data/heimdallcli

  # override with our config
  cp /config.toml.sample /data/heimdalld/config/config.toml

  moniker=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12; echo)

  sed -i -e "s/NODE_NAME/$moniker/g" /data/heimdalld/config/config.toml
fi

echo "Initialization completed successfully"

exec "$@"
