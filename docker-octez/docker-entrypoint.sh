#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

if [ -d "/data/octez-node" ]; then
  octez-node upgrade \
    --data-dir /data/octez-node \
    UPGRADE
fi

echo "Initialization completed successfully"

exec "$@"
