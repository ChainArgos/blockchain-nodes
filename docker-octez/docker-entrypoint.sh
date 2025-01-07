#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

if [ -d "/data/octez-node" ]; then
  octez-node upgrade \
    --data-dir /data/octez-node \
    storage
fi

echo "Initialization completed successfully"

exec "$@"
