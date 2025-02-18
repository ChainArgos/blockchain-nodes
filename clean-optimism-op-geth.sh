#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

docker stop -s 9 optimism-op-node
docker rm ink-op-node

docker stop -s 9 optimism-op-geth
docker rm optimism-op-geth

rm -rf /blockchain/disk4/optimism/
ls -la /blockchain/disk4
