#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

docker stop -s 9 ink-op-node
docker rm ink-op-node

docker stop -s 9 ink-op-geth
docker rm ink-op-geth

rm -rf /blockchain/disk1/ink/
ls -la /blockchain/disk1
