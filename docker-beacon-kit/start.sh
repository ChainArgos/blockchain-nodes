#!/bin/bash
set -eou pipefail

exec beacond \
  start \
  --home /data/beacon-kit
