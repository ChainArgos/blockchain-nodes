#!/bin/bash
set -eou pipefail

exec litecoind \
  -conf=/litecoin.conf \
  -printtoconsole
