#!/bin/bash
set -eou pipefail

exec bor server \
  -config "/config.toml" \
  -bor.heimdall=http://polygon-heimdall:1317
