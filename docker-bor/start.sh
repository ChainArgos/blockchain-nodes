#!/bin/bash
set -eou pipefail

exec bor server \
  -config "/config.toml" \
  -bor.heimdall=http://localhost:1317
