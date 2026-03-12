#!/bin/bash
set -eou pipefail

export BNBCHAIND_HOME_DIR=/data/bnbchaind

exec bnbchaind start \
  --home=${BNBCHAIND_HOME_DIR}
