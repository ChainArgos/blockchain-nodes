#!/bin/bash
set -eou pipefail

exec cardano-node run \
  --config /etc/cardano-node/config.json \
  --database-path /data/cardano-node \
  --host-addr 0.0.0.0 \
  --port 3001 \
  --socket-path /var/run/cardano-node.socket \
  --topology /etc/cardano-node/topology.json
