#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

BNBCHAIND_HOME_DIR=/data/bnbchaind

if [ ! -d "${BNBCHAIND_HOME_DIR}" ]; then
  echo "Initializing bnbchaind node..."

  bnbchaind init --home=${BNBCHAIND_HOME_DIR} --chain-id=Binance-Chain-Tigris --moniker=chainargos

  # Replace with mainnet config files
  cp /config/genesis.json ${BNBCHAIND_HOME_DIR}/config/genesis.json
  cp /config/config.toml ${BNBCHAIND_HOME_DIR}/config/config.toml
  cp /config/app.toml ${BNBCHAIND_HOME_DIR}/config/app.toml
fi

echo "Initialization completed successfully"

exec "$@"
