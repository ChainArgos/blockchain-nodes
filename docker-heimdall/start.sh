#!/bin/bash
set -e

exec heimdalld start \
  --chain=mainnet \
  --home=/data/heimdall \
  --home-client=/data/heimdallcli \
  --rest-server
