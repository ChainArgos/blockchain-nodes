#!/bin/bash

echo "ChainArgos environment variables:"
env | grep CA_

set -eo pipefail

echo "Initialization completed successfully"

exec "$@"
