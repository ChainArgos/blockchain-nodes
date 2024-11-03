#!/bin/bash
set -eou pipefail

if [[ -z "${POLYGON_HEIMDALL_REST_SERVER_URL}" ]]; then
  echo "ERROR: POLYGON_HEIMDALL_REST_SERVER_URL is not set"
  exit 1
fi

exec bor server \
  -config "/config.toml" \
  -bor.heimdall="${POLYGON_HEIMDALL_REST_SERVER_URL}"
