#!/bin/bash
set -eou pipefail

mkdir -pv /data/dogecoin-core

echo "Initialization completed successfully"

exec "$@"
