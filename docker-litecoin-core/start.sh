#!/bin/bash
set -eou pipefail

exec litecoind \
  -conf=/config/litecoin.conf \
  -printtoconsole
