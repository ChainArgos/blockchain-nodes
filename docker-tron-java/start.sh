#!/bin/bash
set -eou pipefail

exec java \
  -jar \
  /FullNode.jar \
  -c \
  /config/main_net_config.conf
