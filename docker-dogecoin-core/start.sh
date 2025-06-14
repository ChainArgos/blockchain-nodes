#!/bin/bash
set -eou pipefail

exec dogecoind \
  -conf=/config/dogecoin.conf \
  -printtoconsole
