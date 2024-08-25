#!/bin/bash
set -eou pipefail

exec cardano-node run \
  --topology /etc/cardano-node/topology.json \
  --database-path /data/cardano-node \
  --socket-path /var/run/cardano-node.socket \
  --host-addr 0.0.0.0 \
  --port 3001 \
  --config /etc/cardano-node/config.json
