#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

FETCHD_HOME_DIR=/data/fetchd
SNAPSHOT_URL="https://storage.googleapis.com/fetch-ai-mainnet-snapshots/fetchhub-4-full.tgz"

if [ ! -d "${FETCHD_HOME_DIR}" ]; then
  echo "Initializing fetchd node..."
  fetchd init chainargos --chain-id fetchhub-4 --home=${FETCHD_HOME_DIR}

  # Replace with mainnet genesis file
  rm ${FETCHD_HOME_DIR}/config/genesis.json
  cp /config/genesis.json.xz ${FETCHD_HOME_DIR}/config/genesis.json.xz
  unxz ${FETCHD_HOME_DIR}/config/genesis.json.xz

  chmod 600 ${FETCHD_HOME_DIR}/config/priv_validator_key.json

  # Download and extract snapshot if CA_USE_SNAPSHOT is set
  if [ "${CA_USE_SNAPSHOT:-false}" = "true" ]; then
    echo "Downloading snapshot from ${SNAPSHOT_URL}..."
    echo "Latest available snapshot timestamp: $(curl -s -I ${SNAPSHOT_URL} | grep -i last-modified | cut -f2- -d' ')"

    # Reset state before applying snapshot
    fetchd tendermint unsafe-reset-all --home=${FETCHD_HOME_DIR} --keep-addr-book

    echo "Extracting snapshot to ${FETCHD_HOME_DIR}..."
    curl -L ${SNAPSHOT_URL} | tar -xzf - -C ${FETCHD_HOME_DIR}

    echo "Snapshot extraction completed successfully"
  fi
fi

echo "Initialization completed successfully"

exec "$@"
