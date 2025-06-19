#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

export GOMEMLIMIT=50GiB

if [ ! -d "/data/geth" ]; then
  echo "Init genesis."

  sonictool --datadir /data/geth --cache 16000 genesis /config/sonic.g
fi

echo "Initialization completed successfully"

exec "$@"
