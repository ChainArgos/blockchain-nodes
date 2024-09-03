#!/bin/bash
set -eou pipefail

exec java \
  -jar \
  /FullNode.jar \
  -c \
  /main_net_config.conf
