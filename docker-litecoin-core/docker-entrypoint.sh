#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eou pipefail

cat <<EOF >> /litecoin.conf
rpcauth=${RPCUSER:-chainargos}:${RPCPASSWORD:-f2977d600d1d3d978f930afad30ee691\$32f2a8b7c82b636789ce4c89932ecb55955c1b7ee8b7169cf4f6e355e6069e1f}
EOF

mkdir -pv /data/litecoin-core

echo "Initialization completed successfully"

exec "$@"
