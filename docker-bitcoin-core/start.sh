#!/bin/bash
set -eou pipefail

exec bitcoind \
  -conf=/config/bitcoin.conf \
  -printtoconsole
