#!/bin/bash
set -eou pipefail

cat <<EOF >> /bitcoin.conf
rpcuser=${RPCUSER:-chainargos}
rpcpassword=${RPCPASSWORD:-`dd if=/dev/urandom bs=33 count=1 2>/dev/null | base64`}
EOF

mkdir -pv /data/bitcoin-core

echo "Initialization completed successfully"

exec "$@"
