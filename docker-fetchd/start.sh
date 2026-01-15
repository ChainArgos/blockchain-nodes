#!/bin/bash
set -eou pipefail

export FETCHD_HOME_DIR=/data/fetchd

# Mainnet seed nodes from https://network.fetch.ai/docs/guides/ledger/references/active-networks
SEEDS="17693da418c15c95d629994a320e2c4f51a8069b@connect-fetchhub.fetch.ai:36456"
SEEDS="${SEEDS},a575c681c2861fe945f77cb3aba0357da294f1f2@connect-fetchhub.fetch.ai:36457"
SEEDS="${SEEDS},d7cda986c9f59ab9e05058a803c3d0300d15d8da@connect-fetchhub.fetch.ai:36458"

exec fetchd start \
  --home=${FETCHD_HOME_DIR} \
  --p2p.seeds="${SEEDS}"
