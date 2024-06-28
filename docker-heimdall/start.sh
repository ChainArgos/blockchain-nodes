#!/bin/bash
set -eou pipefail

exec heimdalld start \
  --chain=mainnet \
  --home=/data/heimdalld \
  --home-client=/data/heimdallcli \
  --eth_rpc_url=http://ethereum-geth:8545
