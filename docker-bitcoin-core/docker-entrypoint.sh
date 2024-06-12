#!/bin/bash
set -e

cat <<EOF >> /bitcoin.conf
rpcuser=${RPCUSER:-chainargos}
rpcpassword=${RPCPASSWORD:-`dd if=/dev/urandom bs=33 count=1 2>/dev/null | base64`}
EOF

mkdir -p /data/bitcoin-core

echo "Initialization completed successfully"

exec "$@"
