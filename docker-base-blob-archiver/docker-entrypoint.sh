#!/bin/bash
set -eou pipefail

echo "ChainArgos environment variables:"
env | grep CA_

echo "Initialization completed successfully"

exec "$@"
