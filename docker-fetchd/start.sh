#!/bin/bash
set -eou pipefail

export FETCHD_HOME_DIR=/data/fetchd

exec fetchd start \
  --home=${FETCHD_HOME_DIR}
