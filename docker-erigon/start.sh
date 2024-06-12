#!/bin/bash
set -eou pipefail

exec erigon \
  --datadir=/data \
  --snapshots=false \
  --internalcl \
  --http.addr=0.0.0.0
