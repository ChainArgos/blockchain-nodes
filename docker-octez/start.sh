#!/bin/bash
set -eou pipefail

exec octez-node \
  run \
  --data-dir /data/octez-node \
  --rpc-addr=0.0.0.0:8732
