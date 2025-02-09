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

  cp /config/app.toml /data/beacon-kit/config/app.toml
  cp /config/client.toml /data/beacon-kit/config/client.toml
  cp /config/config.toml /data/beacon-kit/config/config.toml
  cp /config/genesis.json /data/beacon-kit/config/genesis.json
  cp /config/kzg-trusted-setup.json /data/beacon-kit/config/kzg-trusted-setup.json
fi

if [ ! -f "/data/jwtsecret.hex" ]; then
  echo "Generating JWT secret"

  mkdir -pv /data
  beacond jwt generate -o /data/jwtsecret.hex

  echo ""
fi

echo "Initialization completed successfully"

exec "$@"
