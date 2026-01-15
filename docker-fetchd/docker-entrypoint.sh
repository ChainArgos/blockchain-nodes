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

    SNAPSHOT_FILE="/tmp/snapshot.tgz"

    # Use aria2c for faster multi-connection download
    # -x16: 16 connections per server
    # -s16: 16 splits
    # -k1M: 1MB minimum split size
    echo "Downloading with aria2c (16 connections)..."
    aria2c -x16 -s16 -k1M -d /tmp -o snapshot.tgz "${SNAPSHOT_URL}"

    echo "Extracting snapshot to ${FETCHD_HOME_DIR}..."
    tar -xzf ${SNAPSHOT_FILE} -C ${FETCHD_HOME_DIR}

    rm -f ${SNAPSHOT_FILE}

    echo "Snapshot extraction completed successfully"
  fi
fi

echo "Initialization completed successfully"

exec "$@"
