#!/bin/bash
set -e

if [ ! -f "/data/jwtsecret.hex" ]; then
  echo "Generate the shared secret"

  openssl rand -hex 32 | tr -d "\n" > /data/jwtsecret.hex
fi

echo "Initialization completed successfully"

exec "$@"
