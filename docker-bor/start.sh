#!/bin/bash
set -eou pipefail

until [ "$(curl -s http://polygon-heimdall:26657/status | jq '.result.sync_info.catching_up')" = "false" ]; do
  echo "waiting for heimdall client to be ready"
  sleep 5
done

exec bor server \
  -config "/config.toml"
