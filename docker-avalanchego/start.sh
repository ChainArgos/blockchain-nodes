#!/bin/bash
set -eou pipefail

exec avalanchego \
  --data-dir=/data/avalanchego \
  --http-allowed-hosts=*
