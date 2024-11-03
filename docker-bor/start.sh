#!/bin/bash
set -eou pipefail

if [[ -z "${POLYGON_HEIMDALL_HOSTNAME}" ]]; then
  echo "ERROR: POLYGON_HEIMDALL_HOSTNAME is not set"
  exit 1
fi

if [[ -z "${POLYGON_HEIMDALL_REST_SERVER_URL}" ]]; then
  echo "ERROR: POLYGON_HEIMDALL_REST_SERVER_URL is not set"
  exit 1
fi

until [ "$(curl -s http://"${POLYGON_HEIMDALL_HOSTNAME}":26657/status | jq '.result.sync_info.catching_up')" = "false" ]; do
  echo "waiting for heimdall client to be ready"
  sleep 5
done

exec bor server \
  -config "/config.toml" \
  -bor.heimdall="${POLYGON_HEIMDALL_REST_SERVER_URL}"
