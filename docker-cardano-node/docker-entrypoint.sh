#!/bin/bash
set -eou pipefail

# initialize the data directory
ls -la /data > /dev/null

echo "Initialization completed successfully"

exec "$@"
