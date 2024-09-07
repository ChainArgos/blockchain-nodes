#!/bin/bash
set -eou pipefail

exec avalanchego \
  --data-dir=/data/avalanchego \
  --http-allowed-hosts=* \
  --http-host=0.0.0.0 \
  --http-port=9650
