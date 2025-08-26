#!/bin/bash
set -eou pipefail

exec heimdalld start \
  --chain=mainnet \
  --home=/data/heimdall \
  --rest-server
