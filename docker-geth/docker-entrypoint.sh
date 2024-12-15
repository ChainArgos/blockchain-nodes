#!/bin/bash
set -eou pipefail

echo "ChainArgos environment variables:"
env | grep CA_

# initialize the data directory
ls -la /data > /dev/null

if [ ! -f "/data/jwtsecret.hex" ]; then
  echo "Generating JWT secret"

  mkdir -pv /data
  openssl rand -hex 32 | tr -d "\n" > /data/jwtsecret.hex
fi

echo "Initialization completed successfully"

exec "$@"
