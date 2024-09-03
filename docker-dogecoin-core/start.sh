#!/bin/bash
set -eou pipefail

exec dogecoind \
  -conf=/dogecoin.conf \
  -printtoconsole
