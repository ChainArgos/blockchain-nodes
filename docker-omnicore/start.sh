#!/bin/bash
set -eou pipefail

exec omnicored \
  -conf=/config/omnicore.conf \
  -printtoconsole
