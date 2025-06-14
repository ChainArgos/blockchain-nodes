#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

eval "$(mise activate bash)"

cat <<EOF >> /config/bitcoin.conf
rpcauth=${RPCUSER:-chainargos}:${RPCPASSWORD:-f2977d600d1d3d978f930afad30ee691\$32f2a8b7c82b636789ce4c89932ecb55955c1b7ee8b7169cf4f6e355e6069e1f}
EOF

mkdir -p /root/.bitcoin

cp /config/bitcoin.conf /root/.bitcoin/bitcoin.conf

mkdir -pv /data/bitcoin-core

echo "Initialization completed successfully"

exec "$@"
