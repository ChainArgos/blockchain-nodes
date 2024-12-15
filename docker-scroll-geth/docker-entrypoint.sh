#!/bin/bash
set -eou pipefail

echo "ChainArgos environment variables:"
env | grep CA_

# initialize the data directory
ls -la /data > /dev/null

echo "Initialization completed successfully"

exec "$@"
