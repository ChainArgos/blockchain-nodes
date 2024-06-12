#!/bin/bash
set -eou pipefail

exec bitcoind \
  -conf=/bitcoin.conf \
  -printtoconsole
