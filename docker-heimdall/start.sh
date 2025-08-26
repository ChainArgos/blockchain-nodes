#!/bin/bash
set -eou pipefail

exec heimdalld start \
  --home=/data/heimdall
