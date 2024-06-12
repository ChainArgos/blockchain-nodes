#!/bin/bash
set -eou pipefail

if [ ! -f "/data/jwtsecret.hex" ]; then
  echo "Generate the shared secret"

  mkdir -pv /data
  openssl rand -hex 32 | tr -d "\n" > /data/jwtsecret.hex
fi

echo "Initialization completed successfully"

exec "$@"
