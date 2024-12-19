#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eou pipefail

echo "Initialization completed successfully"

exec "$@"
